import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseService {
  SupabaseService({SupabaseClient? client})
    : client = client ?? Supabase.instance.client;

  final SupabaseClient client;
}
