import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cqaag_app/models/ticket/support_ticket.dart';

part 'ticket_service.g.dart';

class TicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TicketService();

  CollectionReference<Map<String, dynamic>> get _ticketsCollection =>
      _firestore.collection('support_tickets');

  /// Create a new correction or support ticket
  Future<void> createTicket(SupportTicket ticket) async {
    await _ticketsCollection.doc(ticket.id).set(ticket.toJson());
  }

  /// Stream tickets raised by a specific user
  Stream<List<SupportTicket>> streamUserTickets(String userId) {
    return _ticketsCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SupportTicket.fromJson(doc.data())).toList());
  }

  /// Stream all support tickets (Admin / Managers / IT)
  Stream<List<SupportTicket>> streamAllTickets() {
    return _ticketsCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SupportTicket.fromJson(doc.data())).toList());
  }

  /// Update status and resolution notes of a ticket
  Future<void> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
    String? resolutionNotes,
    String? resolvedBy,
  }) async {
    final updateData = <String, dynamic>{
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (resolutionNotes != null) {
      updateData['resolution_notes'] = resolutionNotes;
    }

    if (status == TicketStatus.resolved || status == TicketStatus.closed) {
      updateData['resolved_at'] = DateTime.now().toIso8601String();
      if (resolvedBy != null) {
        updateData['resolved_by'] = resolvedBy;
      }
    }

    await _ticketsCollection.doc(ticketId).update(updateData);
  }

  /// Get total ticket count
  Future<int> getTicketCount() async {
    final snapshot = await _ticketsCollection.count().get();
    return snapshot.count ?? 0;
  }
}

@riverpod
TicketService ticketService(Ref ref) {
  return TicketService();
}

@riverpod
Stream<List<SupportTicket>> userTickets(Ref ref, String userId) {
  return ref.watch(ticketServiceProvider).streamUserTickets(userId);
}

@riverpod
Stream<List<SupportTicket>> allSupportTickets(Ref ref) {
  return ref.watch(ticketServiceProvider).streamAllTickets();
}
