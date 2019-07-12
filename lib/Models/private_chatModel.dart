
class PrivateChatModel {
  String chatId,senderName,msgMedia,mediaUrl,thumbPath,thumbUrl,senderPhone,msgType,timestamp,receiverPhone,isUploaded;

  PrivateChatModel(this.chatId, this.senderName, this.msgMedia, this.senderPhone,this.msgType,this.receiverPhone,this.timestamp,this.isUploaded,this.mediaUrl,this.thumbPath,this.thumbUrl/* ,isSent */);

  PrivateChatModel.fromJson(Map<String, dynamic> json) {
    this.chatId = json['chatId'];
    this.senderName = json['senderName'];
    this.msgMedia = json['msgMedia'];
    this.senderPhone = json['senderPhone'];
    this.msgType = json['msgType'];
    this.receiverPhone = json['receiverPhone'];
    this.timestamp = json['timestamp'];
    this.isUploaded = json['isUploaded'];
    this.mediaUrl =  json['mediaUrl'];
    this.thumbPath =  json['thumbPath'];
    this.thumbUrl =  json['thumbUrl'];
  }
}