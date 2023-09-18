part of 'bloc.dart';

abstract class ConfigEvent extends Equatable {
  const ConfigEvent();

  @override
  List<Object> get props => [];
}

class LoadClasses extends ConfigEvent {}

class AddClass extends ConfigEvent {
  final String name;

  const AddClass(this.name);

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'AddClass { class: $name }';
}

class UpdateClassName extends ConfigEvent {
  final Class cls;
  final String name;
  const UpdateClassName(this.cls, this.name);

  @override
  List<Object> get props => [cls, name];

  @override
  String toString() => 'UpdateClassName { cls: $cls, name: $name }';
}

class DeleteClass extends ConfigEvent {
  final Class cls;

  const DeleteClass(this.cls);

  @override
  List<Object> get props => [cls];

  @override
  String toString() => 'D { DeleteClass: $cls }';
}

class LoadTopics extends ConfigEvent {}

class AddTopic extends ConfigEvent {
  final String name;

  const AddTopic(this.name);

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'AddTopic { topic: $name }';
}

class DeleteTopic extends ConfigEvent {
  final Topic topic;

  const DeleteTopic(this.topic);

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'DeleteTopic { topic: $topic }';
}

class UpdateTopicName extends ConfigEvent {
  final Topic topic;
  final String name;
  const UpdateTopicName(this.topic, this.name);

  @override
  List<Object> get props => [topic, name];

  @override
  String toString() => 'UpdateTopicName { topic: $topic, name: $name }';
}

class UpdateTopicColor extends ConfigEvent {
  final Topic topic;
  final String color;
  const UpdateTopicColor(this.topic, this.color);

  @override
  List<Object> get props => [topic, color];

  @override
  String toString() => 'UpdateTopicColor { topic: $topic, color: $color }';
}

class SortTopics extends ConfigEvent {
  final List<Topic> topics;
  const SortTopics(this.topics);

  @override
  List<Object> get props => [topics];

  @override
  String toString() => 'SortTopics { topics: $topics }';
}

class UpdateControls extends ConfigEvent {
  final Topic topic;
  const UpdateControls(this.topic);

  @override
  List<Object> get props => [topic];

  @override
  String toString() => 'UpdateControls { topic: $topic }';
}

class Synchronize extends ConfigEvent {}

class UpdateConnectionStatus extends ConfigEvent {
  final bool isOnline;
  const UpdateConnectionStatus(this.isOnline);

  @override
  List<Object> get props => [isOnline];

  @override
  String toString() => 'UpdateConnectionStatus { isOnline: $isOnline }';
}
