const { defineComponent, reactive } = Vue;
import { useAuth } from "../../composables/useAuth.js";

export default defineComponent({
  name: "Login",
  template: `
    <div class="login-wrap flex items-center justify-center" style="min-height: 100vh; background: #f0f2f5;">
      <el-card class="login-card" style="width: 400px;">
        <h2 class="text-center mb-4">WMS 로그인</h2>
        <el-form :model="form" label-position="top" @submit.prevent="onSubmit">
          <el-form-item label="사용자 ID">
            <el-input v-model="form.userid" autocomplete="username" />
          </el-form-item>
          <el-form-item label="비밀번호">
            <el-input v-model="form.password" type="password" show-password autocomplete="current-password" />
          </el-form-item>
          <el-button type="primary" class="w-full" native-type="submit" :loading="loading">로그인</el-button>
        </el-form>
        <p class="text-xs text-gray-500 mt-3">교육용: 백엔드 /api/auth/login 준비 후 사용</p>
      </el-card>
    </div>
  `,
  setup() {
    const { login } = useAuth();
    const form = reactive({ userid: "", password: "" });
    const loading = Vue.ref(false);

    const onSubmit = async () => {
      loading.value = true;
      try {
        await login(form.userid, form.password);
        window.location.hash = "#/";
      } catch {
        /* 메시지는 useAuth */
      } finally {
        loading.value = false;
      }
    };

    return { form, onSubmit, loading };
  },
});
