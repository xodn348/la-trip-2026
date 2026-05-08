# LA & Las Vegas 2026 🌴

여행 위시리스트 시각화 — Leaflet + 정적 HTML로 만든 지도. 외부 앱·API 키 없이 동작.

## 사용법

```bash
# 로컬에서 보기 (간단)
open index.html
# 또는 가벼운 서버
python3 -m http.server 8080
# → http://localhost:8080
```

## 장소 추가/수정하는 법

1. `places.csv`에 한 줄 추가:
   ```csv
   "장소 이름",도시,카테고리,출처,평점,"메모","Google Maps 검색용 주소나 이름"
   ```
   - **카테고리**: `hotel` `restaurant` `cafe` `attraction` `beach` `museum` `park` `shopping` `theme_park` `viewpoint` `theater` `zoo`
   - **출처**: `booked` (예약완료) / `wife` (와이프) / `self` (남편)
2. 지오코더 실행 → `places.json` 갱신:
   ```bash
   ./geocode.sh
   ```
   (캐시되어 있어서 새로 추가한 줄만 OpenStreetMap에 쿼리)
3. 페이지 새로고침. 끝.

## 데이터 구조

- `places.csv` — 사람이 편집하는 소스
- `places.json` — 빌드 산출물 (좌표 포함). HTML이 직접 fetch
- `.geocode-cache.json` — 지오코딩 결과 캐시 (rate-limit 방지)

## 기능

- 📍 55개 장소 (와이프 리스트 + 예약된 숙소)
- 🗺️ 다크 테마 지도 (CartoDB Dark)
- 🔍 검색 + 도시·카테고리·출처 필터
- 🎯 클러스터링 (확대하면 펼쳐짐)
- 📱 모바일 대응
- 🔗 각 장소 → 구글맵 바로가기 링크

## 배포 (옵션)

GitHub Pages에 push하면 휴대폰에서도 볼 수 있음:
```bash
gh repo create la-trip-2026 --public --source=. --push
gh repo edit --enable-pages --pages-branch main
```
