from qgis.core import QgsExpression, QgsFeatureRequest

# Assuming you have already loaded the layer in QGIS and it is the active layer
layer = iface.activeLayer()

# Calculate the area of each feature and add it to a new field "area"
area_idx = layer.fields().indexFromName('area_overlap')
if area_idx == -1:
    layer.startEditing()
    layer.dataProvider().addAttributes([QgsField('area_overlap', QVariant.Double)])
    layer.updateFields()

expression = QgsExpression('$area')
context = QgsExpressionContext()
context.setFeature(QgsFeature())
with edit(layer):
    for feature in layer.getFeatures():
        context.setFeature(feature)
        value = expression.evaluate(context)
        feature['area_overlap'] = value
        layer.updateFeature(feature)

# Commit changes after calculating area
layer.commitChanges()

# Apply the equation and save the result to the new field "Cs"
area_overlap_idx = layer.fields().indexFromName('area_overlap')
sp2area_idx = layer.fields().indexFromName('sp2area')
Cs_idx = layer.fields().indexFromName('Cs')

expression_str = 'round(("area_overlap" / "area") * ("area_overlap" / "sp2area"), 2)'

layer.startEditing()
if Cs_idx == -1:
    layer.dataProvider().addAttributes([QgsField('Cs', QVariant.Double)])
    layer.updateFields()

expression = QgsExpression(expression_str)
context = QgsExpressionContext()
context.appendScope(QgsExpressionContextUtils.globalScope())
context.appendScope(QgsExpressionContextUtils.projectScope())
context.appendScope(QgsExpressionContextUtils.layerScope(layer))

with edit(layer):
    for feature in layer.getFeatures():
        context.setFeature(feature)
        value = expression.evaluate(context)
        feature['Cs'] = value
        layer.updateFeature(feature)

# Commit changes after calculating Cs
layer.commitChanges()

# Select features with "Cs" < 0.1 and delete them permanently
request = QgsFeatureRequest().setFilterExpression('Cs < 0.1')
selected_features_to_delete = [f.id() for f in layer.getFeatures(request)]

with edit(layer):
    layer.deleteFeatures(selected_features_to_delete)

# Commit changes after deleting features
layer.commitChanges()
