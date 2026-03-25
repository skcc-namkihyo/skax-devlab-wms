// 모든 모듈 라우트 중앙 관리 (분산 금지)
const { createRouter, createWebHashHistory } = VueRouter;

const routes = [
  { path: "/", component: () => import("./views/Home.js") },
  {
    path: "/login",
    component: () => import("./views/auth/Login.js"),
    meta: { public: true },
  },
  // logs 모듈 — Task wms-005 (배치·이력 조회 UI 스캐폴드)
  {
    path: "/logs/list",
    component: () => import("./views/logs/pages/List.js"),
  },
  {
    path: "/logs/create",
    component: () => import("./views/logs/pages/Create.js"),
  },
  {
    path: "/logs/edit/:id?",
    component: () => import("./views/logs/pages/Edit.js"),
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem("token");
  const isPublic = to.meta?.public === true;

  if (isPublic) {
    if (token && to.path === "/login") {
      next("/");
    } else {
      next();
    }
    return;
  }

  if (!token) {
    next("/login");
  } else {
    next();
  }
});

export default router;
