const { defineComponent } = Vue;

export default defineComponent({
  name: "Home",
  template: `
    <div class="home">
      <el-card shadow="never">
        <h1 class="text-xl font-semibold mb-2">WMS 시스템에 오신 것을 환영합니다</h1>
        <p class="text-gray-500">좌측 메뉴에서 기능을 선택하세요. 로그·이력 모듈은 초기 스캐폴드 기반입니다.</p>
      </el-card>
    </div>
  `,
});
