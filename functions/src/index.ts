import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

//private chat
exports.privateNotification = functions.database.ref('/messages/private/{pushId}/{id}')
    .onCreate(async (snapshot, context) => {
        const original = snapshot.val();
        console.log(original);

        const msg = original.msgType == '3' || original.msgType == '4' ? 'Audio Song'
            : original.msgType == '2' ? 'Video'
                : original.msgType == '1'  ? 'Image'
                :original.msgMedia;
        console.log('msg : ' + msg);

        const payload = {
            notification: {
                title: 'Message from: ' + original.senderName,//change this to name p1
                body: msg,
                icon: 'https://goo.gl/Fz9nrQ',
                badge: '1',
                sound: 'default'
            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                id: original.chatId,
                phone: original.senderPhone.toString(),
                msg: msg,
                time: original.timestamp.toString()
            }
        }

        const db = admin.firestore();
        const devicesRef = db.collection('userTokens').where('id', '==', parseInt(original.recPin.toString()));

        // get the user's tokens and send notifications
        var tokens = <any>[];
        const devices = await devicesRef.get();
        devices.forEach(async result => {
            const token = result.data().token;
            console.log("token:" + token);
            tokens.push(token);
        });
        // console.log("tokens:" + tokens);
        return admin.messaging().sendToDevice(tokens, payload);
    });



//public chat
exports.publicNotification = functions.database.ref('/messages/group/{pushId}/{id}')
    .onCreate(async (snapshot, context) => {
        const original = snapshot.val();
        console.log(original);

        const msg = original.msgType == '3' || original.msgType == '4' ? 'Audio Song'
            : original.msgType == '2' ? 'Video'
                : original.msgType == '1'  ? 'Image'
                :original.msgMedia;
        console.log('msg : ' + msg);

        const payload = {
            notification: {
                title: 'Message in : ' + original.groupName,//change this to name p1
                body: msg,
                icon: 'https://goo.gl/Fz9nrQ',
                badge: '1',
                sound: 'default'
            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                id: original.chatId,
                phone: original.senderPhone.toString(),
                msg: msg,
                time: original.timestamp.toString()
            }
        }

        const db = admin.firestore();

        var tokens = <any>[];
        

        var groupMembers = original.members;
        for(let j= 0;j<groupMembers.length;j++){
            if(groupMembers[j].toString() == original.senderPin.toString()){
                groupMembers.splice(j,1);
            }
        }
        console.log('[]'+groupMembers);
        
        // members
        for(let i = 0; i<groupMembers.length;i++){
            const devicesRef = await  db.collection('userTokens').where('id', '==', parseInt(groupMembers[i].toString()));
            const devices = await devicesRef.get();
            // console.log('deviceslen : '+ devices.size);

            devices.forEach(async result => {
                const token = result.data().token;
                // console.log("token adding from org.mem--dev:" + token);
                tokens.push(token);
            });
        }

        console.log("tokens:" + tokens);
        return admin.messaging().sendToDevice(tokens, payload);

    });
