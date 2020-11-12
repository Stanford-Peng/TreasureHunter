// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');
// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();
// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

//reference:https://www.geodatasource.com/developers/javascript
function distance(lat1, lon1, lat2, lon2, unit) {
	if ((lat1 === lat2) && (lon1 === lon2)) {
		return 0;
	}
	else {
		var radlat1 = Math.PI * lat1/180;
		var radlat2 = Math.PI * lat2/180;
		var theta = lon1-lon2;
		var radtheta = Math.PI * theta/180;
		var dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
		if (dist > 1) {
			dist = 1;
		}
		dist = Math.acos(dist);
		dist = dist * 180/Math.PI;
		dist = dist * 60 * 1.1515;
		if (unit==="K") { dist = dist * 1.609344 }
		if (unit==="N") { dist = dist * 0.8684 }
		return dist;
	}
}

// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

//
exports.findItems = functions.https.onCall(async(data, context) => {
    // Grab the long parameter.
    const long = parseFloat(data.long);
    const lat = parseFloat(data.lat);
    const radius = parseFloat(data.radius)
    const userPoint = new admin.firestore.GeoPoint(lat,long)
    //console.log(userPoint)
    functions.logger.log(userPoint);

    // Checking that the user is authenticated.
    if (!context.auth) {
        // Throwing an HttpsError so that the client gets the error details.
        throw new functions.https.HttpsError('failed-precondition', 'The function must be called ' +
            'while authenticated.');
    }

    const itemLocationsReference = db.collection('ItemLocation');
    const snapshot = await itemLocationsReference.get();
    functions.logger.log(snapshot);
    if (snapshot.empty) {
        console.log('No matching documents.');
        return;
    }
    // const doc = itemLocationsReference.doc('WwrQpVnY623iSY57mCW9');
    // console.log(doc.data());
    let items = [];
    snapshot.forEach(
        (doc) => {
            const itemLocation = doc.get("location")
            const itemID = doc.get("itemID")

            if(distance(userPoint.latitude, userPoint.longitude, itemLocation.latitude, itemLocation.longitude,"K")*1000 < radius){
                let exist = false;
                items.forEach(
                    (item, index) => {
                        if (item["itemID"] === itemID ){
                            exist = true;
                            item["itemCount"] += doc.get("itemCount");
                            item["id"].push(doc.id)                    
                        } 
                    }
                )
                if(exist){
                    //skip
                } else {
                    items.push({
                        id:[doc.id],
                        itemID:doc.get("itemID"),
                        location:doc.get("location"),
                        itemCount:doc.get("itemCount")
                    }
                    );
                }
                //items.push({id:doc.id, data:doc.data()});
            }
            functions.logger.log("doc:", itemLocation, {structuredData: true});
        }
    )
    return items;
  }
)

    // Send back a message that we've succesfully written the message
    // {
    //     data =     {
    //         itemCount = 1;
    //         itemID = "Normal Oyster";
    //         location =         {
    //             "_latitude" = "-37.919177";
    //             "_longitude" = "145.117854";
    //         };
    //     };
    //     id = x8F5H9dEOfgcHNzoeocG;
    // }
// exports.findItems = functions.https.onRequest(async(req, res) => {
//     // Grab the long parameter.
//     functions.logger.log(req.query.long, typeof req.query.long);
//     functions.logger.log(req.query.lat, typeof req.query.lat);
//     const long = parseFloat(req.query.long);
//     const lat = parseFloat(req.query.lat);
//     functions.logger.log(long, typeof long);
//     functions.logger.log(lat, typeof lat);

//     const userPoint = new admin.firestore.GeoPoint(lat,long)
//     //console.log(userPoint)
//     functions.logger.log(userPoint);

//     const itemLocationsReference = db.collection('ItemLocation');
//     const snapshot = await itemLocationsReference.get();
//     if (snapshot.empty) {
//         console.log('No matching documents.');
//         return;
//     }
//     // const doc = itemLocationsReference.doc('WwrQpVnY623iSY57mCW9');
//     // console.log(doc.data());
//     let items = [];
//     snapshot.forEach(
//         (doc) => {
//             const itemLocation = doc.get("location")
            
//             if(distance(userPoint.latitude, userPoint.longitude, itemLocation.latitude, itemLocation.longitude,"K")*1000 < 10){
//                 items.push({id:doc.id, data:doc.data()});
//             }
//             functions.logger.log("doc:", itemLocation, {structuredData: true});
//         }
//     )

//     // Send back a message that we've succesfully written the message
//     // [
//     //     {
//     //         "id": "WwrQpVnY623iSY57mCW9",
//     //         "data": {
//     //             "location": {
//     //                 "_latitude": -37.919211,
//     //                 "_longitude": 145.117854
//     //             },
//     //             "name": "Pearl Oyster"
//     //         }
//     //     }
//     // ]
//     res.json(items);
//   }
// )

