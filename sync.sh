#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
#  ซิงก์ต้นแบบจากรีโปหลัก → รีโปสำหรับให้ทีมงานดู (GitHub Pages)
# ═══════════════════════════════════════════════════════════════════════════
#  ใช้:  bash sync.sh            (คัดลอก + commit + push ให้เลย)
#        bash sync.sh --dry      (ดูว่าจะเปลี่ยนอะไรบ้าง ไม่แตะ git)
#
#  🔴 การแก้ไขทั้งหมดทำที่รีโปหลักเท่านั้น — ไฟล์ในรีโปนี้เป็นสำเนา
#     แก้ที่นี่โดยตรงจะถูกเขียนทับรอบถัดไป
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

SRC="/Applications/XAMPP/xamppfiles/htdocs/TIMS/design"
DST="$(cd "$(dirname "$0")" && pwd)"
DRY=""
[ "${1:-}" = "--dry" ] && DRY="ใช่"

[ -f "$SRC/Prototype_TIMS.html" ] || { echo "❌ ไม่พบรีโปหลักที่ $SRC"; exit 1; }

echo "── คัดลอกจาก $SRC"
cp "$SRC/Prototype_TIMS.html" "$DST/index.html"
rm -rf "$DST/fonts" "$DST/logos"
cp -R "$SRC/fonts" "$DST/fonts"
cp -R "$SRC/logos" "$DST/logos"

# ── ตัวปรับแต่งโลโก้ + มาสคอต "น้อง TIMS" ────────────────────────────────
#  เปิดให้ทีมงานดูแล้ว 19 ก.ย. 2569 — ฝ่ายฝึกใช้พิจารณาว่าจะเลือกโลโก้/มาสคอตแบบไหน
#  ดูได้ที่  https://jdksx.github.io/tims-prototype/logo.html
#  🔴 ไฟล์นี้อ้าง logo-fonts.js ไฟล์เดียว (ฟอนต์ฝังเป็น base64 ในตัว ไม่ดึงจากเน็ต)
#     และไม่อ้าง logos/ เลย ⇒ คัดลอกแค่สองไฟล์นี้พอ
cp "$SRC/tims-logo-maker.html" "$DST/logo.html"
cp "$SRC/logo-fonts.js"        "$DST/logo-fonts.js"

# กัน GitHub Pages เอาไฟล์ไปผ่าน Jekyll (ไฟล์ใหญ่ 2 MB ไม่ต้องให้มันประมวลผล)
touch "$DST/.nojekyll"

SIZE=$(du -sh "$DST" | cut -f1)
echo "── รวมขนาด $SIZE"

if [ -n "$DRY" ]; then
  echo "── โหมดดูอย่างเดียว — ไม่แตะ git"
  git -C "$DST" status --short
  exit 0
fi

cd "$DST"
if git diff --quiet && git diff --cached --quiet; then
  echo "✅ ไม่มีอะไรเปลี่ยน — ต้นแบบตรงกับรีโปหลักอยู่แล้ว"
  exit 0
fi

REV=$(git -C "$SRC/.." rev-parse --short HEAD)
git add -A
git commit -q -m "ซิงก์ต้นแบบจากรีโปหลัก (commit $REV)"
git push -q
echo "✅ อัปเดตแล้ว — ทีมงานรีเฟรชหน้าเว็บได้เลย (อ้างอิง commit $REV ของรีโปหลัก)"
