import router from "./router.js";

// CDN 라이브러리 로드 확인
if (!window.Vue) throw new Error("Vue 라이브러리 로드 실패");
if (!window.ElementPlus) throw new Error("Element Plus 라이브러리 로드 실패");
if (!window.axios) throw new Error("Axios 라이브러리 로드 실패");

const { createApp, defineAsyncComponent } = Vue;

const app = createApp({
  template: `<AppLayout></AppLayout>`,
  components: {
    AppLayout: defineAsyncComponent(
      () => import("./components/layout/AppLayout.js"),
    ),
  },
});

app.config.errorHandler = (err) => {
  console.error("Global Error:", err);
  ElMessage.error("오류가 발생했습니다.");
};

// Element Plus 한국어 (CDN locale 스크립트 전역명이 환경마다 다를 수 있음)
const koLocale =
  window.ElementPlusLocaleKo || window.ElementPlus?.locale?.ko;
if (koLocale) {
  app.use(ElementPlus, { locale: koLocale });
} else {
  app.use(ElementPlus);
}

app.use(router);

if (window.ElementPlusIconsVue) {
  for (const [name, component] of Object.entries(window.ElementPlusIconsVue)) {
    app.component(name, component);
  }
}

app.mount("#app");
