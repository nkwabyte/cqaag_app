// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ticketService)
final ticketServiceProvider = TicketServiceProvider._();

final class TicketServiceProvider
    extends $FunctionalProvider<TicketService, TicketService, TicketService>
    with $Provider<TicketService> {
  TicketServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ticketServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ticketServiceHash();

  @$internal
  @override
  $ProviderElement<TicketService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TicketService create(Ref ref) {
    return ticketService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TicketService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TicketService>(value),
    );
  }
}

String _$ticketServiceHash() => r'28af0d19b5323238831ebe74e65ee5b54ea7ff13';

@ProviderFor(userTickets)
final userTicketsProvider = UserTicketsFamily._();

final class UserTicketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SupportTicket>>,
          List<SupportTicket>,
          Stream<List<SupportTicket>>
        >
    with
        $FutureModifier<List<SupportTicket>>,
        $StreamProvider<List<SupportTicket>> {
  UserTicketsProvider._({
    required UserTicketsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userTicketsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userTicketsHash();

  @override
  String toString() {
    return r'userTicketsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SupportTicket>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SupportTicket>> create(Ref ref) {
    final argument = this.argument as String;
    return userTickets(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserTicketsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userTicketsHash() => r'5f2efb5879f7485fa31be6996dac0c249808b085';

final class UserTicketsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SupportTicket>>, String> {
  UserTicketsFamily._()
    : super(
        retry: null,
        name: r'userTicketsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserTicketsProvider call(String userId) =>
      UserTicketsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userTicketsProvider';
}

@ProviderFor(allSupportTickets)
final allSupportTicketsProvider = AllSupportTicketsProvider._();

final class AllSupportTicketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SupportTicket>>,
          List<SupportTicket>,
          Stream<List<SupportTicket>>
        >
    with
        $FutureModifier<List<SupportTicket>>,
        $StreamProvider<List<SupportTicket>> {
  AllSupportTicketsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allSupportTicketsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allSupportTicketsHash();

  @$internal
  @override
  $StreamProviderElement<List<SupportTicket>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SupportTicket>> create(Ref ref) {
    return allSupportTickets(ref);
  }
}

String _$allSupportTicketsHash() => r'5723dbf673103e1accae217e7e5a0a36f32ac0f7';
