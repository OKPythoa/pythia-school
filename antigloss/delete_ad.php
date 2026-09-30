<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

function out(int $code, array $data): never {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    exit;
}
function readKey(): string {
    foreach ([dirname(__DIR__, 2) . '/private/publisher_config.php', dirname(__DIR__) . '/private/publisher_config.php'] as $path) {
        if (!is_file($path)) continue;
        $value = require $path;
        if (is_array($value) && !empty($value['ANTIGLOSS_PUBLISH_KEY'])) return (string) $value['ANTIGLOSS_PUBLISH_KEY'];
    }
    return (string) getenv('ANTIGLOSS_PUBLISH_KEY');
}
function cleanId(string $value): string {
    $value = trim($value);
    if ($value === '' || !preg_match('/^[a-zA-Z0-9._-]+$/', $value)) out(400, ['success' => false, 'error' => 'invalid_ad_id']);
    return $value;
}

$need = trim(readKey());
$got = trim((string) ($_SERVER['HTTP_X_ANTIGLOSS_PUBLISH_KEY'] ?? $_POST['key'] ?? ''));
$raw = file_get_contents('php://input') ?: '';
$body = json_decode($raw, true);
if (is_array($body) && $got === '') $got = trim((string) ($body['key'] ?? ''));
if ($need === '' || $got === '' || !hash_equals($need, $got)) out(403, ['success' => false, 'error' => 'publisher_key_required']);

$adId = cleanId((string) ($body['id'] ?? $_POST['id'] ?? ''));
$root = dirname(__DIR__);
$adsPath = $root . '/content/ads.json';
$ads = is_file($adsPath) ? json_decode((string) file_get_contents($adsPath), true) : null;
if (!is_array($ads) || !isset($ads['ads']) || !is_array($ads['ads'])) out(500, ['success' => false, 'error' => 'invalid_ads_file']);

$kept = [];
$removed = null;
foreach ($ads['ads'] as $ad) {
    if (is_array($ad) && ($ad['id'] ?? '') === $adId) {
        $removed = $ad;
        continue;
    }
    $kept[] = $ad;
}
if ($removed === null) out(404, ['success' => false, 'error' => 'ad_not_found']);

$bak = $adsPath . '.bak-delete-' . date('Ymd-His');
@copy($adsPath, $bak);
$ads['ads'] = array_values($kept);
$json = json_encode($ads, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
$tmp = $adsPath . '.tmp-' . bin2hex(random_bytes(4));
if (@file_put_contents($tmp, $json, LOCK_EX) === false || !@rename($tmp, $adsPath)) {
    @unlink($tmp);
    out(500, ['success' => false, 'error' => 'ads_write_failed']);
}
out(200, ['success' => true, 'id' => $adId, 'backup' => basename($bak)]);
