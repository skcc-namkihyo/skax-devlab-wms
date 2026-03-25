/**
 * 사이드바 메뉴 정의 (중앙 관리)
 * /gen-ui: logs 모듈 라우트 등록
 */
export const menuItems = [
  {
    type: "item",
    path: "/",
    title: "홈",
    icon: "House",
  },
  {
    type: "sub",
    title: "기존 기능 개선",
    icon: "Setting",
    children: [
      {
        type: "sub",
        title: "로그·이력",
        icon: "Document",
        children: [
          { type: "item", path: "/logs/list", title: "로그 목록" },
          { type: "item", path: "/logs/create", title: "로그 등록" },
        ],
      },
    ],
  },
];
