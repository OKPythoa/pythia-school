<?php
declare(strict_types=1);
header('X-Content-Type-Options: nosniff');
$root = dirname(__DIR__);
$json = $root . '/content/issues.json';
$cover = $root . '/assets/issues/' . date('Y-m') . '.png';
if (is_file($json)) {
    $data = json_decode((string)file_get_contents($json), true);
    $issues = is_array($data['issues'] ?? null) ? $data['issues'] : [];
    $month = date('Y-m');
    $hit = null;
    foreach ($issues as $row) {
        if (is_array($row) && (($row['month'] ?? '') === $month) && !empty($row['cover'])) {
            $hit = $row['cover'];
            break;
        }
    }
    if (!$hit && $issues) {
        $last = $issues[0];
        if (is_array($last) && !empty($last['cover'])) $hit = $last['cover'];
    }
    if (is_string($hit) && $hit !== '') {
        $path = $hit[0] === '/' ? ($root . $hit) : ($root . '/' . $hit);
        if (is_file($path)) $cover = $path;
    }
}
if (!is_file($cover)) {
    http_response_code(404);
    exit;
}
$ext = strtolower(pathinfo($cover, PATHINFO_EXTENSION));
$mime = $ext === 'jpg' || $ext === 'jpeg' ? 'image/jpeg' : ($ext === 'webp' ? 'image/webp' : 'image/png');
header('Content-Type: ' . $mime);
header('Cache-Control: public, max-age=600');
header('Content-Length: ' . filesize($cover));
readfile($cover);
