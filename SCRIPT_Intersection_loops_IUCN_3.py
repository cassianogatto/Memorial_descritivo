
#Na tora 1 a 1
layer = iface.activeLayer()
layer.startEditing()
factor_field_name = "10x_factor"
field_index = layer.fields().indexFromName(factor_field_name)
if field_index ==-1:
    layer.addAttribute(QgsField(factor_field_name, QVariant.Int))
field_index = layer.fields().indexFromName(factor_field_name)
layer.commitChanges()
print(layer.fields()[factor_field_name])
expression = QgsExpression("if(area/sp2area > 10, 10, if (area/sp2area < 0.1, 0, 1))")
context = QgsExpressionContext()
context.appendScopes(QgsExpressionContextUtils.globalProjectLayerScopes(layer))
layer.startEditing()
# ate´aqui tá rolando mas o loop abaixo não...
for feature in layer.getFeatures():
    print(feature)
    context.setFeature(feature)
    feature['10x_factor'] = expression.evaluate(context)
    layer.updateFeature(feature)
layer.commitChanges()










# https://opensourceoptions.com/blog/pyqgis-calculate-geometry-and-field-values-with-the-qgis-python-api/
#2. Create a New Field
#We’re going to need a new field (i.e. column) in the attribute table to store the result of our calculation. To do this, get the layer’s data provider, which will give you access to the attributes, then add a new attribute.
#Here, I’m adding two fields named ‘len_test_m’ and ‘calc’. The field ‘len_test_m’ will hold the the length of each line in my vector file after I calculate geometry. The field ‘calc’ will hold the result of a simple mathematical calculation that I’ll describe below. Values for each field are decimal numbers so the type is set to a double.

pv = layer.dataProvider()
pv.addAttributes([QgsField('len_test_m', QVariant.Double), QgsField('calc', QVariant.Double)])

#After adding the fields update the layer for the changes to take effect.
layer.updateFields()
expression1 = QgsExpression('$length')
expression2 = QgsExpression('"field1"/"field2"')

#First create the QgsExpressionContext object. Then give it the scope of the layer you’re working with.
context = QgsExpressionContext()
context.appendScopes(QgsExpressionContextUtils.globalProjectLayerScopes(layer))

#For this example, I’m going to perform each field calculation individually. You may want to experiment with putting multiple field calculations in the same loop. Theoretically, it should work as long as your calculations don’t depend on the results of another calculation.
#Geometry Calculation
with edit(layer):
    for f in layer.getFeatures():
        context.setFeature(f)
        f['len_test_m'] = expression1.evaluate(context)
        layer.updateFeature(f)







import os
from qgis.core import (
    QgsApplication,
    QgsVectorLayer,
    QgsProject,
    QgsFeatureRequest,
    QgsExpression,
    QgsField,
    QgsVectorFileWriter
)

# Initialize QGIS application
QgsApplication.setPrefixPath("C:/OSGeo4W64/apps/qgis", True)
qgs = QgsApplication([], False)
qgs.initQgis()

# Set the geopackage file path
#geopackage_path = "C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d'amazone/les_animaux_intersect.gpkg"
geopackage_path = "C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d'amazone/les_animaux.gpkg"

# Set the input layer names
input_layer_names = ['teste'] #'sp_4901_5000_x_tous']

# Loop through each layer
for layer_name in input_layer_names:
    #print(layer_name)
    layer_name_with_path = "{}|layername={}".format(geopackage_path, layer_name)
    #print(layer_name_with_path)
    # Load the vector layer
    layer = QgsVectorLayer(layer_name_with_path, layer_name, "ogr")
    if not layer.isValid():
        print("Layer {} could not be loaded!".format(layer_name))
        continue
    print("layer = {}".format(layer))
    # Enable editing
    #layer.startEditing()
    factor_field_name = "10x_factor"
    field_index = layer.fields().indexFromName(factor_field_name)
    if field_index ==-1:
        factor_field = QgsField(factor_field_name, QVariant.Int)
        layer.addAttribute(factor_field)
        field_index = layer.fields().indexFromName(factor_field_name)
    layer.commitChanges()
    print(layer.fields()[factor_field_name])

    # não estou conseguindo criar direito ou referenciar a nova coluna 10x_factor

    # Create a new field for Cs
    cs_field_name = "Cs"
    cs_field = QgsField(cs_field_name, QVariant.Double, "double", 10, 3)
    layer.addAttribute(cs_field)

    expression = QgsExpression("if(area/sp2area > 10, 10, if (area/sp2area < 0.1, 0, 1))")
    context = QgsExpressionContext()
    context.appendScopes(QgsExpressionContextUtils.globalProjectLayerScopes(layer))
    with edit(layer):
        for feature in layer.getFeatures():
            context.setFeature(feature)
            feature[field_name] = expression.evaluate(context)
            layer.updateFeature(feature)

    layer.commitChanges()





    # Create a new field for area_overlap
    field_name = "area_overlap"
    field_index = layer.fields().indexFromName(field_name)
    if field_index == -1:
        field = QgsField(field_name, QVariant.Int)
        layer.addAttribute(field)
        field_index = layer.fields().indexFromName(field_name)

    # Calculate the feature area and update the field
    expression = QgsExpression("$area")
    context = QgsExpressionContext()
    context.appendScopes(QgsExpressionContextUtils.globalProjectLayerScopes(layer))
    #expression.setExpressionContext(context)

#       for feature in layer.getFeatures():
#            value = expression.evaluate(feature)
#            feature[field_index] = round(value, 0)
#            layer.updateFeature(feature)

    with edit(layer):
        for feature in layer.getFeatures():
            context.setFeature(feature)
            f['area_overlap'] = expression.evaluate(context)
            layer.updateFeature(feature)




        # Save the changes
        layer.commitChanges()

        # Create a new field for Cs
        cs_field_name = "Cs"
        cs_field = QgsField(cs_field_name, QVariant.Double, "double", 10, 3)
        layer.addAttribute(cs_field)

        # Calculate Cs for each feature
        sp2area = 123.45  # Replace with the actual value of sp2area
        overlap_area_index = layer.fields().indexFromName(
            "overlap_area")  # Assuming you have another field called "overlap_area"

        for feature in layer.getFeatures():
            overlap_area = feature.attributes()[overlap_area_index]
            area = feature.attributes()[field_index]
            cs = round((overlap_area / area) * (overlap_area / sp2area), 3)
            feature[layer.fields().indexFromName(cs_field_name)] = cs
            layer.updateFeature(feature)

        # Filter the features based on Cs >= 0.1
        expression = QgsExpression("Cs >= 0.1")
        request = QgsFeatureRequest(expression)
        selected_features = [feature for feature in layer.getFeatures(request)]

        # Export the selected features to a new layer
        output_layer_name = "{}_Cs01".format(layer_name)
        output_layer_path = "{}|layername={}".format(geopackage_path, output_layer_name)
        QgsVectorFileWriter.writeAsVectorFormatV2(
            selected_features,
            output_layer_path,
            "utf-8",
            layer.crs(),
            "GPKG",
            layerOptions=['SPATIAL_INDEX=YES']
        )

        # Delete the original layer
        QgsProject.instance().removeMapLayer(layer)
        os.remove(layer.dataProvider().dataSourceUri())

    # Exit QGIS application
    qgs.exitQgis()

















#
##Tous_les_animaux_d'Amazone_ensemble
##C:\Users\Cliente\Documents\Cassiano\IUCN\Q_GIS\Les_animaux_d'amazone\les_animaux.gpkg
#
## select the desired layer
#layer_path = "C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d'amazone/les_animaux.gpkg"  # Replace with the path to your GeoPackage file
#layer_name = "Tous_les_animaux_d'Amazone_ensemble"  # Replace with the name of the layer within the GeoPackage
#
#layer = QgsVectorLayer(layer_path + "|layername=" + layer_name, "Tous_les_animaux_d\'Amazone_ensemble", "ogr")
#if not layer.isValid():
#    print("Layer failed to load!")
#    
#layer = iface.activeLayer()  # Get the active layer
## layer.id()
## layer.featureCount()
#
## create a list of expressions 
## Define the total number of rows and the chunk size

import time

start_time = time.time()

#print("--- %s seconds ---" % (time.time() - start_time))



layer = iface.activeLayer()
# CANT SELECT THE RIGHT LAYER TO RUN THE LOOP WITH THIS
#layer_path = "C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d'amazone/les_animaux.gpkg"
#layer = QgsVectorLayer("C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d\'amazone/les_animaux.gpkg|layername=Tous_animaux", "Tous_animaux", "ogr")
#

layer = iface.activeLayer()

start_time = time.time()
id_start = 1000
id_end = 5014
chunk_size = 100

for i in range(id_start, id_end, chunk_size):
    start = i  + 1
    end = min(i + chunk_size, id_end)
    expression = f" \"fid\" >= {start} AND \"fid\" <= {end} "
    print(expression)
    layer.selectByExpression(expression)
    parameters = {
        'INPUT':QgsProcessingFeatureSourceDefinition("C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d\'amazone/les_animaux.gpkg|layername=Tous_animaux", 
        selectedFeaturesOnly=True, featureLimit=-1, geometryCheck=QgsFeatureRequest.GeometryAbortOnInvalid),
        #'FILTER_EXPRESSION': expression,
        #'OVERLAY': "C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d\'amazone/les_animaux.gpkg|layername=Tous_les_animaux_d\'Amazone_ensemble",
        'OVERLAY': layer,
        #"C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d\'amazone/les_animaux.gpkg|layername=Tous_animaux",
            #QgsProcessingFeatureSourceDefinition("C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d\'amazone/les_animaux.gpkg|layername=Tous_animaux",         selectedFeaturesOnly=False, featureLimit=-1, geometryCheck=QgsFeatureRequest.GeometryAbortOnInvalid),
        'INPUT_FIELDS':['fid','sp','group','area'],
        'OVERLAY_FIELDS':['fid','sp','group','area'],
        'OVERLAY_FIELDS_PREFIX':'sp2',
        'OUTPUT':f'ogr:dbname=\'C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d\\\'amazone/les_animaux_intersect.gpkg\' table= \"sp_{start}_{end}_x_tous\" (geom)',
        'GRID_SIZE': None
    }
    processing.run("native:intersection", parameters)
    timex = (time.time() - start_time)/60
    print(f"--- %s minutes  start = {start} ---" % (timex))


timex = (time.time() - start_time)/60
print(f"--- %s minutes  start = {start} ---" % (timex))



# MERGING

start_time = time.time()

layer_inter_path = "C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d'amazone/les_animaux_intersect.gpkg"

id_start = 1000
id_end = 1300
chunk_size = 100
parameters = []
for i in range(id_start, id_end, chunk_size):
    start = i  + 1
    end = min(i + chunk_size, id_end)
    express = f"sp_{start}_{end}_x_tous"
    print(express)
    expression = f"QgsVectorLayer(layer_inter_path + \"|layername=\" + \"{express}\", \"{express}\", \"ogr\"),"
    print(expression)
    parameters.append(expression)

parameters

# MANUAL EDIT!!!
# MANUAL EDIT 
parameters = [QgsVectorLayer(layer_inter_path + "|layername=" + "sp_1001_1100_x_tous", "sp_1001_1100_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_1101_1200_x_tous", "sp_1101_1200_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_1201_1300_x_tous", "sp_1201_1300_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_1301_1400_x_tous", "sp_1301_1400_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_1401_1500_x_tous", "sp_1401_1500_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_1501_1600_x_tous", "sp_1501_1600_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_1601_1700_x_tous", "sp_1601_1700_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_1701_1800_x_tous", "sp_1701_1800_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_1801_1900_x_tous", "sp_1801_1900_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_1901_2000_x_tous", "sp_1901_2000_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_2001_2100_x_tous", "sp_2001_2100_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_2101_2200_x_tous", "sp_2101_2200_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_2201_2300_x_tous", "sp_2201_2300_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_2301_2400_x_tous", "sp_2301_2400_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_2401_2500_x_tous", "sp_2401_2500_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_2501_2600_x_tous", "sp_2501_2600_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_2601_2700_x_tous", "sp_2601_2700_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_2701_2800_x_tous", "sp_2701_2800_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_2801_2900_x_tous", "sp_2801_2900_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_2901_3000_x_tous", "sp_2901_3000_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_3001_3100_x_tous", "sp_3001_3100_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_3101_3200_x_tous", "sp_3101_3200_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_3201_3300_x_tous", "sp_3201_3300_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_3301_3400_x_tous", "sp_3301_3400_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_3401_3500_x_tous", "sp_3401_3500_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_3501_3600_x_tous", "sp_3501_3600_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_3601_3700_x_tous", "sp_3601_3700_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_3701_3800_x_tous", "sp_3701_3800_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_3801_3900_x_tous", "sp_3801_3900_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_3901_4000_x_tous", "sp_3901_4000_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_4001_4100_x_tous", "sp_4001_4100_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_4101_4200_x_tous", "sp_4101_4200_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_4201_4300_x_tous", "sp_4201_4300_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_4301_4400_x_tous", "sp_4301_4400_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_4401_4500_x_tous", "sp_4401_4500_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_4501_4600_x_tous", "sp_4501_4600_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_4601_4700_x_tous", "sp_4601_4700_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_4701_4800_x_tous", "sp_4701_4800_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_4801_4900_x_tous", "sp_4801_4900_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_4901_5000_x_tous", "sp_4901_5000_x_tous", "ogr")]


processing.run("native:mergevectorlayers", {'LAYERS': parameters,
'CRS':QgsCoordinateReferenceSystem('EPSG:4326'),
'OUTPUT':f'ogr:dbname=\'C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d\\\'amazone/les_animaux_intersect.gpkg\' table= \"tous_1001_5000\" (geom)'
})











path_gpkg = "C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d'amazone/les_animaux_intersect.gpkg"
#layer_name = "Tous_les_animaux_d'Amazone_ensemble"
#
#layer = QgsVectorLayer(layer_path + "|layername=" + layer_name, "Tous_les_animaux_d\'Amazone_ensemble", "ogr")

#Merge overlaps este último não funcionou só de 100 a 140...
min = 0
max = 140
star_time = time.time()
processing.run("native:mergevectorlayers", {'LAYERS':[
#lay101_110, #lay111_120, #QgsProcessingFeatureSourceDefinition("C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d\'amazone/les_animaux_intersect.gpkg|layername=sp_111_120_x_tous", selectedFeaturesOnly=False, featureLimit=-1, geometryCheck=QgsFeatureRequest.GeometryAbortOnInvalid),
QgsVectorLayer(layer_inter_path + "|layername=" + "sp_1_100_x_tous", "sp_1_100_x_tous", "ogr"),
QgsVectorLayer(layer_inter_path + "|layername=" + "tous101_140", "tous101_140", "ogr"),
#QgsVectorLayer(layer_path + "|layername=" + "sp_121_140_x_tous", "sp_121_140_x_tous", "ogr")
#"C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d\'amazone/les_animaux.gpkg|layername=tous101_120",
#"C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d\'amazone/les_animaux.gpkg|layername=sp_121_140_x_tous"
],
'CRS':QgsCoordinateReferenceSystem('EPSG:4326'),
'OUTPUT':f'ogr:dbname=\'C:/Users/Cliente/Documents/Cassiano/IUCN/Q_GIS/Les_animaux_d\\\'amazone/les_animaux_intersect.gpkg\' table= \"tous_{min}_{max}\" (geom)'})

timex = (time.time() - start_time)/60
print("--- %s minutes ---" % (timex))



