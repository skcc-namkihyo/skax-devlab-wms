const { reactive } = Vue;

const store = reactive({
  user: null,
  token: localStorage.getItem("token"),
  isLoading: false,

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
