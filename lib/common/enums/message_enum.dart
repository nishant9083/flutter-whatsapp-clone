enum MessageEnum {
  text('text'),
  image('image'),
  audio('audio'),
  video('video'),
  document('document'),
  gif('gif');

  const MessageEnum(this.type);
  final String type;
}

// Using an extension
// Enhanced enums

extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'audio':
        return MessageEnum.audio;
      case 'image':
        return MessageEnum.image;
      case 'text':
        return MessageEnum.text;
      case 'gif':
        return MessageEnum.gif;
      case 'video':
        return MessageEnum.video;
      case 'document':
        return MessageEnum.document;
      default:
        return MessageEnum.text;
    }
  }
}
