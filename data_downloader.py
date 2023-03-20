import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import csv

# initialize Firebase credentials
cred = credentials.Certificate('uw-gis-project-firebase-adminsdk-qai1z-404da4088d.json')
firebase_admin.initialize_app(cred)

# initialize Firestore client
db = firestore.client()

# define the collection and document to retrieve data from
collection_name = 'plants'
# define the output file name
output_file = 'output.csv'

# retrieve all documents in the collection
docs = db.collection(collection_name).stream()

# save data to CSV file
with open(output_file, mode='w', newline='') as csv_file:
    writer = csv.writer(csv_file)
    
    # write the headers
    headers_written = False
    
    # loop over all documents in the collection
    for doc in docs:
        # get the data from the current document
        data = doc.to_dict()
        
        # write the headers if not yet written
        if not headers_written:
            writer.writerow(data.keys())
            headers_written = True
        
        # write the data
        writer.writerow(data.values())
