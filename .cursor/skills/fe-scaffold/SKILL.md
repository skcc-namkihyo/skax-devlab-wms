---
description: "프로젝트 초기 파일 생성 | Create initial project structure for Vue 3 CDN"
---

# fe-scaffold

## 개요

Vue 3 CDN 기반 프로젝트의 초기 파일 구조를 생성합니다. index.html, app.js, router.js, api.js, store.js의 5개 핵심 파일을 생성합니다.

⚠️ **이 Skill은 수동 발동 전용입니다 (disable-model-invocation)**

**사용 시점**: 새로운 프론트엔드 프로젝트 초기화

## 템플릿 / 패턴

### index.html

```html
<!DOCTYPE html>
<html lang="ko">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>WMS 시스템</title>

    <!-- Vue 3 -->
    <script src="https://unpkg.com/vue@3.5.18/dist/vue.global.js"></script>
    <!-- Vue Router -->
    <script src="https://unpkg.com/vue-router@4.5.1/dist/vue-router.global.js"></script>

    <!-- Element Plus -->
    <link
      rel="stylesheet"
      href="https://unpkg.com/element-plus@2.11.4/dist/index.css"
    />
    <script src="https://unpkg.com/element-plus@2.11.4/dist/index.full.js"></script>
    <script src="https://unpkg.com/element-plus@2.11.4/dist/locale/ko.js"></script>

    <!-- Element Plus Icons -->
    <script src="https://unpkg.com/@element-plus/icons-vue@2.3.2/dist/index.iife.js"></script>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com/3.4.17"></script>

    <!-- Axios -->
    <script src="https://unpkg.com/axios@1.11.0/dist/axios.min.js"></script>

    <!-- 스타일 -->
    <link rel="stylesheet" href="./styles/main.css" />
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="./app.js"></script>
  </body>
</html>
```

### app.js

```javascript
import router from "./router.js";

// CDN 라이브러리 로드 확인
if (!window.Vue) throw new Error("Vue 라이브러리 로드 실패");
if (!window.ElementPlus) throw new Error("Element Plus 라이브러리 로드 실패");
if (!window.axios) throw new Error("Axios 라이브러리 로드 실패");

const { createApp, defineAsyncComponent } = Vue;

// defineAsyncComponent 사용: () => import() 직접 등록 시 [object Promise] 렌더링 버그 방지
const app = createApp({
  template: `<AppLayout></AppLayout>`,
  components: {
    AppLayout: defineAsyncComponent(
      () => import("./components/layout/AppLayout.js"),
    ),
  },
});

// 전역 에러 핸들러 (createApp 이후에 설정)
app.config.errorHandler = (err) => {
  console.error("Global Error:", err);
  ElMessage.error("오류가 발생했습니다.");
};

app.use(ElementPlus, { locale: ElementPlusLocaleKo });
app.use(router);

// Element Plus 아이콘 전역 등록 (CDN 환경)
if (window.ElementPlusIconsVue) {
  for (const [name, component] of Object.entries(window.ElementPlusIconsVue)) {
    app.component(name, component);
  }
}

app.mount("#app");
```

### router.js

```javascript
// 모든 모듈 라우트 중앙 관리 (분산 금지)
const { createRouter, createWebHashHistory } = VueRouter;

const routes = [
  { path: "/", component: () => import("./views/Home.js") },
  {
    path: "/login",
    component: () => import("./views/auth/Login.js"),
    meta: { public: true },
  },
  // 모듈 라우트: views/{module}/pages/{Page}.js
  { path: "/user/list", component: () => import("./views/user/pages/List.js") },
  {
    path: "/user/create",
    component: () => import("./views/user/pages/Create.js"),
  },
  {
    path: "/user/edit/:id?",
    component: () => import("./views/user/pages/Edit.js"),
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

/**
 * 라우트 가드 — 인증 확인
 * - 공개 페이지(meta.public=true): 인증 없이 접근 허용
 * - 비공개 페이지: token 없으면 /login 리다이렉트
 * - /login 접근 시 이미 로그인 상태면 홈(/)으로 리다이렉트
 */
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
```

### api.js

```javascript
const api = axios.create({
  baseURL: "http://localhost:8080/api",
  timeout: 30000,
  headers: { "Content-Type": "application/json" },
});

// 요청 인터셉터 (JWT 토큰 추가)
api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// 응답 인터셉터 (에러 처리)
// ⚠️ 401 + 403 모두 처리 (Spring Security는 인증 미설정 시 403 반환)
api.interceptors.response.use(
  (response) => response.data,
  (error) => {
    const status = error.response?.status;
    if (status === 401 || status === 403) {
      localStorage.removeItem("token");
      localStorage.removeItem("refreshToken");
      window.location.hash = "#/login";
    }
    throw error;
  },
);

export default api;
```

### store.js

```javascript
const { reactive, computed } = Vue;

const store = reactive({
  // 상태
  user: null,
  token: localStorage.getItem("token"),
  isLoading: false,

  // 액션
  setUser(user) {
    this.user = user;
  },

  setToken(token) {
    this.token = token;
    if (token) {
      localStorage.setItem("token", token);
    } else {
      localStorage.removeItem("token");
    }
  },

  setLoading(value) {
    this.isLoading = value;
  },
});

export default store;
```

### styles/main.css

```css
/* 전역 스타일 */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html,
body {
  height: 100%;
}

body {
  font-family:
    -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu,
    Cantarell, sans-serif;
  font-size: 14px;
  line-height: 1.5;
  color: #303133;
  background-color: #ffffff;
}

#app {
  height: 100%;
}

/* Tailwind 유틸리티 추가 */
.flex {
  display: flex;
}
.justify-between {
  justify-content: space-between;
}
.items-center {
  align-items: center;
}
.gap-4 {
  gap: 1rem;
}
.gap-5 {
  gap: 1.25rem;
}
.p-4 {
  padding: 1rem;
}
.p-5 {
  padding: 1.25rem;
}
.mb-4 {
  margin-bottom: 1rem;
}
.mb-5 {
  margin-bottom: 1.25rem;
}
```

### components/layout/AppLayout.js

> ⚠️ 로그인 페이지에서는 헤더/사이드바를 숨기고, 로그아웃은 반드시 `useAuth().logout()` 사용

```javascript
const { defineComponent, ref, computed, defineAsyncComponent } = Vue;
import store from "../../store.js";
import { useAuth } from "../../composables/useAuth.js";

export default defineComponent({
  name: "AppLayout",
  components: {
    SidebarMenu: defineAsyncComponent(() => import("./SidebarMenu.js")),
  },
  template: `
        <!-- 로그인 페이지: 레이아웃 없이 router-view만 렌더링 -->
        <div v-if="isLoginPage">
            <router-view></router-view>
        </div>

        <!-- 일반 페이지: 헤더 + 사이드바 + 콘텐츠 -->
        <div v-else class="app-layout">
            <div class="app-header">
                <div class="flex justify-between items-center px-5 py-3">
                    <div class="flex items-center gap-4">
                        <el-icon class="cursor-pointer" @click="toggleSidebar"><Fold /></el-icon>
                        <h1 class="text-lg font-semibold text-gray-800">WMS 창고관리시스템</h1>
                    </div>
                    <div class="flex items-center gap-4">
                        <span class="text-sm text-gray-500">{{ displayName }}</span>
                        <el-button text @click="handleLogout">로그아웃</el-button>
                    </div>
                </div>
            </div>
            <div class="app-container">
                <div class="app-sidebar" :class="{ collapsed: sidebarCollapsed }">
                    <SidebarMenu :collapsed="sidebarCollapsed" />
                </div>
                <div class="app-content">
                    <router-view></router-view>
                </div>
            </div>
        </div>
    `,
  setup() {
    const route = VueRouter.useRoute();
    const { logout } = useAuth();
    const sidebarCollapsed = ref(false);

    const isLoginPage = computed(() => route.path === "/login");
    const displayName = computed(() => store.user?.username || "사용자");

    const toggleSidebar = () => {
      sidebarCollapsed.value = !sidebarCollapsed.value;
    };

    const handleLogout = () => {
      ElMessageBox.confirm("정말 로그아웃 하시겠습니까?", "로그아웃 확인")
        .then(() => logout())
        .catch(() => {});
    };

    return {
      sidebarCollapsed,
      toggleSidebar,
      handleLogout,
      isLoginPage,
      displayName,
    };
  },
});
```

### views/Home.js

```javascript
const { defineComponent } = Vue;

export default defineComponent({
  name: "Home",
  template: `
        <div class="home">
            <h1>WMS 시스템에 오신 것을 환영합니다</h1>
            <p>메뉴에서 원하는 기능을 선택하세요.</p>
        </div>
    `,
});
```

## 디렉토리 구조

```
frontend/
├── index.html              # 메인 HTML (CDN 라이브러리, type="module" 진입점)
├── app.js                  # Vue 앱 초기화
├── router.js               # Vue Router 설정 (모든 라우트 중앙 관리)
├── api.js                  # Axios 설정
├── store.js                # 전역 상태 관리
├── sidebar.js              # 사이드바 메뉴 구성 (신규 모듈 메뉴 등록)
├── styles/
│   └── main.css            # 전역 스타일
├── components/
│   ├── layout/
│   │   └── AppLayout.js    # 메인 레이아웃
│   └── common/             # 공통 컴포넌트
├── views/
│   ├── Home.js
│   ├── auth/
│   │   └── Login.js
│   └── {module}/           # 모듈별 디렉토리
│       ├── pages/          # 페이지 컴포넌트
│       │   ├── List.js
│       │   ├── Create.js
│       │   └── Edit.js
│       └── components/     # 모듈 전용 컴포넌트
└── composables/            # Vue 3 Composables
```

## 사용 가이드

1. **프로젝트 디렉토리 생성**: `frontend/`
2. **파일 생성**: 위의 5개 핵심 파일 생성
3. **Live Server 실행**: VSCode Live Server 또는 Python `python -m http.server 8000`
4. **URL 접근**: http://localhost:5500 (Live Server) 또는 http://localhost:8000
5. **컴포넌트 추가**: `components/` 디렉토리에 추가
6. **페이지 추가**: `views/` 디렉토리에 추가
7. **라우트 추가**: `router.js`에 경로 추가

## 체크리스트

- [ ] 프로젝트 디렉토리 생성
- [ ] index.html 생성 및 CDN 링크 확인
- [ ] app.js 생성 (Vue 앱 초기화)
- [ ] router.js 생성 (라우팅 설정)
- [ ] api.js 생성 (Axios 설정)
- [ ] store.js 생성 (전역 상태)
- [ ] styles/main.css 생성
- [ ] components/layout/AppLayout.js 생성
- [ ] views/Home.js 생성
- [ ] Live Server로 실행 확인
- [ ] 브라우저 개발자 도구에서 에러 확인
