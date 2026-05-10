# SpeakFlow Design Example Set

이 폴더의 시안은 아래 규칙을 직접 반영한 예시 페이지입니다.

## 고정 규칙

- Background: `#E6E7E3`
- Accent: `#B6E63A`
- Heading text: `#1A1A1A`
- Body text: `#5F5F5F`
- Typography: `Inter` 중심
- Radius: `24px` 이상
- Shadow: `0px 12px 32px rgba(0,0,0,0.08)`
- Icon style: 배경 없는 단색 아이콘
- Text gradient: 사용 금지
- 임의 색상 추가: 금지

## 포함 파일

- `speakflow-stage.css`
- `01-student-home.html`
- `02-instructor-dashboard.html`
- `03-admin-dashboard.html`
- `speakflow-wave.css`
- `04-student-home-wave.html`
- `speakflow-ripple.css`
- `05-student-home-ripple-system.html`
- `speakflow-voice.css`
- `06-student-home-voice-ripple.html`

## 의도

이 세 파일은 예쁜 컨셉 목업보다, 앞으로 다른 섹션과 페이지를 계속 찍어낼 수 있는
"통제된 디자인 시스템 예시"로 쓰기 위한 목적입니다.

추가로 `04-student-home-wave.html`은 사용자가 제공한 `speak.png`의 로고 감각을
검정 + 형광 라임 조합으로 재해석하고, 물결이 퍼져나가는 인상을 레이아웃 전반에
반영한 별도 변형 시안입니다. 기존 예제는 그대로 유지됩니다.

`05-student-home-ripple-system.html`은 사용자가 제시한
`중심 → 반응 → 확산 → 잔향` 규칙을 더 직접적으로 적용한 시안입니다.
섹션별 중심점, 정보 위계, 감쇠형 링, 클릭 리플, 절제된 reveal, reduced-motion 대응까지 포함합니다.

현재 `04-student-home-wave.html`, `05-student-home-ripple-system.html`,
`06-student-home-voice-ripple.html`은 `assets/ripple-logo.png`를 실제 로고 이미지로 사용합니다.

`06-student-home-voice-ripple.html`은 같은 시스템 안에서
“물결”보다 “목소리가 퍼져나가는 압력과 잔향”을 더 강하게 느끼도록 만든 변형입니다.
원형 반복보다 타원형 확산, 웨이브라인, 발화점, 방향성 있는 아크를 더 적극적으로 사용합니다.
