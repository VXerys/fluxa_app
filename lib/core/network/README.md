core/network — Network clients and helpers

Purpose:
- Provide `supabase_client.dart` wrapper and any network utilities.
- Centralize retry/timeouts if needed.

Guidelines:
- Core exposes client only; feature queries belong in feature data layer.
- Initialize client in `InitialBinding` or `main.dart`.