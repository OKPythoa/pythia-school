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

$need = trim(readKey());
$got = trim((string) ($_SERVER['HTTP_X_ANTIGLOSS_PUBLISH_KEY'] ?? $_POST['key'] ?? ''));
if ($need === '' || $got === '' || !hash_equals($need, $got)) out(403, ['success' => false, 'error' => 'publisher_key_required']);

$month = trim((string) ($_POST['month'] ?? ''));
if (!preg_match('/^\d{4}-(0[1-9]|1[0-2])$/', $month)) out(400, ['success' => false, 'error' => 'month_required']);

$root = dirname(__DIR__);
$path = $root . '/content/issues.json';
$data = is_file($path) ? json_decode((string) file_get_contents($path), true) : [];
if (!is_array($data)) $data = [];
if (!isset($data['issues']) || !is_array($data['issues'])) $data['issues'] = [];
$data['magazine'] = 'The AntiGloss';

$coverRel = null;
if (!empty($_FILES['image']) && is_uploaded_file($_FILES['image']['tmp_name'])) {
    $file = $_FILES['image'];
    if (($file['size'] ?? 0) <= 0 || ($file['size'] ?? 0) > 8000000) out(400, ['success' => false, 'error' => 'image_too_large']);
    $info = @getimagesize($file['tmp_name']);
    if (!is_array($info)) out(400, ['success' => false, 'error' => 'invalid_image']);
    $formats = [IMAGETYPE_JPEG => 'jpg', IMAGETYPE_PNG => 'png', IMAGETYPE_WEBP => 'webp'];
    $ext = $formats[$info[2] ?? 0] ?? null;
    if ($ext === null) out(400, ['success' => false, 'error' => 'unsupported_image_type']);
    $dir = $root . '/assets/issues';
    if (!is_dir($dir) && !mkdir($dir, 0755, true)) out(500, ['success' => false, 'error' => 'mkdir_failed']);
    $dest = $dir . '/' . $month . '.' . $ext;
    foreach (glob($dir . '/' . $month . '.*') ?: [] as $old) {
        if (is_file($old) && $old !== $dest) @unlink($old);
    }
    if (!move_uploaded_file($file['tmp_name'], $dest)) out(500, ['success' => false, 'error' => 'upload_failed']);
    $coverRel = '/assets/issues/' . $month . '.' . $ext;
}

$found = false;
foreach ($data['issues'] as &$issue) {
    if (!is_array($issue) || ($issue['month'] ?? '') !== $month) continue;
    $found = true;
    if ($coverRel) $issue['cover'] = $coverRel;
    $issue['updatedAt'] = gmdate(DATE_ATOM);
}
unset($issue);
if (!$found) {
    $data['issues'][] = [
        'month' => $month,
        'cover' => $coverRel,
        'updatedAt' => gmdate(DATE_ATOM),
    ];
}
usort($data['issues'], static function ($a, $b) {
    return strcmp((string) ($b['month'] ?? ''), (string) ($a['month'] ?? ''));
});

$json = json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
$tmp = $path . '.tmp-' . bin2hex(random_bytes(4));
if (@file_put_contents($tmp, $json, LOCK_EX) === false || !@rename($tmp, $path)) {
    @unlink($tmp);
    out(500, ['success' => false, 'error' => 'issues_write_failed']);
}
out(200, ['success' => true, 'month' => $month, 'cover' => $coverRel, 'issues' => $data['issues']]);
