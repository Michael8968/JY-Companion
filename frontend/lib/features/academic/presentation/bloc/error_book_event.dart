import '../../domain/entities/subject.dart';

sealed class ErrorBookEvent {
  const ErrorBookEvent();
}

class ErrorBookLoadEvent extends ErrorBookEvent {
  const ErrorBookLoadEvent({this.subject});
  final Subject? subject;
}

class ErrorBookReviewEvent extends ErrorBookEvent {
  const ErrorBookReviewEvent(this.errorId);
  final String errorId;
}
