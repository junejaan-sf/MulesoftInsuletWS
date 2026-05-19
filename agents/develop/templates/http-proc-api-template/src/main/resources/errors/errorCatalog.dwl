%dw 2.0
/**
 * Error catalog builder for proc-API transaction error IDs.
 * Each entry maps to a specific downstream SAPI operation failure.
 *
 * Convention: {sourceSystem}-NNN (three digits, starting from 001).
 * Replace the function entries to match your proc API's downstream SAPIs.
 * Reference: used in common-connectivity.xml errorTransactionId and v-transaction-error-params.dwl.
 *
 * Example (accounts-proc-api):
 *   genericIntegrationError  -> "Drupal-000"
 *   primaryOperationFailed   -> "Drupal-001"  (sfl-crm-persona-sys-api)
 *   secondaryOperationFailed -> "Drupal-002"  (sfl-consents-sys-api)
 *   tertiaryOperationFailed  -> "Drupal-003"  (sfl-campaigns-sys-api)
 */
fun buildErrorCatalog(sourceSystem: String) = {
  genericIntegrationError:  sourceSystem ++ "-000",
  primaryOperationFailed:   sourceSystem ++ "-001",
  secondaryOperationFailed: sourceSystem ++ "-002",
  tertiaryOperationFailed:  sourceSystem ++ "-003"
}
