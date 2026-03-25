import router from "../../router.js";

const { defineComponent, computed } = Vue;

/**
 * 사이드바 메뉴 — 경로는 sidebar.js·router.js와 동일하게 유지
 */
export default defineComponent({
  name: "SidebarMenu",
  props: {
    collapsed: { type: Boolean, default: false },
  },
  template: `
    <el-menu
      :default-active="activeMenu"
      :collapse="collapsed"
      router
      background-color="#304156"
      text-color="#bfcbd9"
      active-text-color="#409eff"
      class="sidebar-el-menu"
    >
      <el-menu-item index="/">
        <el-icon><House /></el-icon>
        <span>홈</span>
      </el-menu-item>
      <el-sub-menu index="improve">
        <template #title>
          <el-icon><Setting /></el-icon>
          <span>기존 기능 개선</span>
        </template>
        <el-sub-menu index="logs">
          <template #title>
            <el-icon><Document /></el-icon>
            <span>로그·이력</span>
          </template>
          <el-menu-item index="/logs/list">로그 목록</el-menu-item>
          <el-menu-item index="/logs/create">로그 등록</el-menu-item>
        </el-sub-menu>
      </el-sub-menu>
    </el-menu>
  `,
  setup() {
    const activeMenu = computed(() => router.currentRoute.value.path);
    return { activeMenu };
  },
});
