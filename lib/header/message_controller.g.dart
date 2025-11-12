// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MessageController)
const messageControllerProvider = MessageControllerProvider._();

final class MessageControllerProvider
    extends $NotifierProvider<MessageController, List<Message>> {
  const MessageControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messageControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messageControllerHash();

  @$internal
  @override
  MessageController create() => MessageController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }
}

String _$messageControllerHash() => r'd9714e4f4f26f4baa04f92d20074fca834bf1f91';

abstract class _$MessageController extends $Notifier<List<Message>> {
  List<Message> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Message>, List<Message>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Message>, List<Message>>,
              List<Message>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
