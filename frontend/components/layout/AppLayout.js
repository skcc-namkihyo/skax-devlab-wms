const { defineComponent, ref, computed, defineAsyncComponent } = Vue;
import router from "../../router.js";
import store from "../../store.js";
import { useAuth } from "../../composables/useAuth.js";

export default defineComponent({
  name: "AppLayout",
  components: {
    SidebarMenu: defineAsyncComponent(() => import("./SidebarMenu.js")),
  },
  template: `
    <div v-if="isLoginPage">
      <router-view></router-view>
    </div>
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
    const { logout } = useAuth();
    const sidebarCollapsed = ref(false);

    const route = computed(() => router.currentRoute.value);
    const isLoginPage = computed(() => route.value.path === "/login");
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
