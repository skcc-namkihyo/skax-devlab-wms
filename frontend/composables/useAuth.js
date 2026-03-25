import api from "../api.js";
import store from "../store.js";

const { computed } = Vue;

export const useAuth = () => {
  const isAuthenticated = computed(() => !!store.token);
  const currentUser = computed(() => store.user);

  /**
   * 로그인 — BE 응답 형식에 맞춰 data 추출
   */
  const login = async (userId, password) => {
    try {
      const response = await api.post("/auth/login", {
        userid: userId,
        password: password,
      });
      const payload = response?.data ?? response;
      const data = payload?.data ?? payload;

      if (data?.accessToken) {
        store.setToken(data.accessToken);
      }
      store.setUser({
        userid: data.userid,
        username: data.username,
        usergroupcode: data.usergroupcode,
      });
      if (data.refreshToken) {
        localStorage.setItem("refreshToken", data.refreshToken);
      }

      ElMessage.success("로그인되었습니다.");
      return data;
    } catch (err) {
      ElMessage.error(
        err.response?.data?.result_message || "로그인에 실패했습니다.",
      );
      throw err;
    }
  };

  const logout = () => {
    store.setToken(null);
    store.setUser(null);
    localStorage.removeItem("refreshToken");
    ElMessage.success("로그아웃되었습니다.");
    window.location.hash = "#/login";
  };

  return { isAuthenticated, currentUser, login, logout };
};
