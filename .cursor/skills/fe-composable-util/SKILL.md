---
description: "useApi, useAuth, useFormValidation 유틸리티 | Core composable utilities"
---

# fe-composable-util

## 개요

Vue 3 Composition API 기반 핵심 유틸리티 Composable 3개를 제공합니다. API 통신(useApi), 인증(useAuth), 폼 검증(useFormValidation)을 처리합니다.

**사용 시점**: 컴포넌트에서 API, 인증, 폼 검증이 필요할 때

## 템플릿 / 패턴

### useApi (API 통신)

```javascript
// composables/useApi.js
import api from '../api.js';

export const useApi = () => {
    const loading = Vue.ref(false);
    const error = Vue.ref(null);

    /**
     * API 요청 (GET, POST, PUT, DELETE)
     * @param {string} method HTTP 메서드 (get, post, put, delete)
     * @param {string} url 요청 URL
     * @param {object} data 요청 데이터 (선택사항)
     * @param {object} config Axios 설정 (선택사항)
     * @returns {Promise} 응답 데이터
     */
    const request = async (method, url, data = null, config = {}) => {
        loading.value = true;
        error.value = null;

        try {
            let response;
            switch (method.toLowerCase()) {
                case 'get':
                    response = await api.get(url, { params: data, ...config });
                    break;
                case 'post':
                    response = await api.post(url, data, config);
                    break;
                case 'put':
                    response = await api.put(url, data, config);
                    break;
                case 'delete':
                    response = await api.delete(url, config);
                    break;
                default:
                    throw new Error(`Unknown method: ${method}`);
            }
            return response;
        } catch (err) {
            error.value = err.response?.data?.message || err.message || '요청 처리 중 오류 발생';
            ElMessage.error(error.value);
            throw err;
        } finally {
            loading.value = false;
        }
    };

    return { loading, error, request };
};
```

**사용 예시**:
```javascript
setup() {
    const { loading, error, request } = useApi();

    const fetchUser = async () => {
        try {
            const response = await request('get', '/user/1');
            console.log('사용자 정보:', response);
        } catch (err) {
            // 에러는 useApi에서 자동 처리
        }
    };

    return { loading, fetchUser };
}
```

### useAuth (인증)

> ⚠️ BE API 필드명 매핑에 주의: `userid`(소문자), `accessToken`, `refreshToken`

```javascript
// composables/useAuth.js
import api from '../api.js';
import store from '../store.js';

const { computed } = Vue;

export const useAuth = () => {
    const isAuthenticated = computed(() => !!store.token);
    const currentUser = computed(() => store.user);

    /**
     * 로그인
     * BE POST /api/auth/login 호출
     * 요청: { userid, password }
     * 응답: { result_code, data: { accessToken, refreshToken, userid, username, usergroupcode } }
     */
    const login = async (userId, password) => {
        try {
            const response = await api.post('/auth/login', {
                userid: userId,
                password: password
            });
            const data = response.data || response;

            // accessToken → localStorage('token')에 저장
            store.setToken(data.accessToken);
            // 사용자 정보 객체로 저장
            store.setUser({
                userid: data.userid,
                username: data.username,
                usergroupcode: data.usergroupcode
            });
            // refreshToken은 별도 저장
            if (data.refreshToken) {
                localStorage.setItem('refreshToken', data.refreshToken);
            }

            ElMessage.success('로그인되었습니다.');
            return data;
        } catch (err) {
            ElMessage.error(err.response?.data?.result_message || '로그인에 실패했습니다.');
            throw err;
        }
    };

    /**
     * 로그아웃
     * token, refreshToken 모두 삭제 후 /login 이동
     */
    const logout = () => {
        store.setToken(null);
        store.setUser(null);
        localStorage.removeItem('refreshToken');
        ElMessage.success('로그아웃되었습니다.');
        window.location.hash = '#/login';
    };

    /**
     * 토큰 갱신
     * BE POST /api/auth/refresh 호출
     * 요청: { refreshToken }
     * 응답: { result_code, data: { accessToken } }
     */
    const refreshToken = async () => {
        const savedRefreshToken = localStorage.getItem('refreshToken');
        if (!savedRefreshToken) {
            logout();
            return;
        }
        try {
            const response = await api.post('/auth/refresh', {
                refreshToken: savedRefreshToken
            });
            const data = response.data || response;
            store.setToken(data.accessToken);
            return data;
        } catch (err) {
            logout();
            throw err;
        }
    };

    return { isAuthenticated, currentUser, login, logout, refreshToken };
};
```

**사용 예시**:
```javascript
setup() {
    const { isAuthenticated, currentUser, login, logout } = useAuth();

    const handleLogin = async () => {
        await login('admin', 'admin123');  // userid 기반 (email 아님)
    };

    return { isAuthenticated, currentUser, handleLogin, logout };
}
```

### useFormValidation (폼 검증)

```javascript
// composables/useFormValidation.js
export const useFormValidation = () => {
    /**
     * 이메일 검증
     * @param {string} email 이메일
     * @returns {boolean}
     */
    const validateEmail = (email) => {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    };

    /**
     * 비밀번호 검증
     * 8자 이상, 대문자/소문자/숫자/특수문자 조합
     * @param {string} password 비밀번호
     * @returns {boolean}
     */
    const validatePassword = (password) => {
        const re = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
        return re.test(password);
    };

    /**
     * 전화번호 검증 (형식: 01X-XXXX-XXXX)
     * @param {string} phone 전화번호
     * @returns {boolean}
     */
    const validatePhoneNumber = (phone) => {
        const re = /^01[0-9]-\d{3,4}-\d{4}$/;
        return re.test(phone);
    };

    /**
     * 폼 전체 검증
     * @param {object} form 폼 데이터
     * @param {object} rules 검증 규칙
     * @returns {object} 에러 객체
     */
    const validateForm = (form, rules) => {
        const errors = {};

        for (const [field, fieldRules] of Object.entries(rules)) {
            const value = form[field];

            for (const rule of fieldRules) {
                // 필수 필드 검증
                if (rule.required && !value) {
                    errors[field] = rule.message || `${field}은(는) 필수입니다.`;
                    break;
                }

                // 커스텀 검증
                if (rule.validator && value && !rule.validator(value)) {
                    errors[field] = rule.message;
                    break;
                }

                // 최소/최대 길이
                if (rule.min && value && value.length < rule.min) {
                    errors[field] = `${field}은(는) 최소 ${rule.min}자 이상이어야 합니다.`;
                    break;
                }

                if (rule.max && value && value.length > rule.max) {
                    errors[field] = `${field}은(는) 최대 ${rule.max}자 이하여야 합니다.`;
                    break;
                }
            }
        }

        return errors;
    };

    return {
        validateEmail,
        validatePassword,
        validatePhoneNumber,
        validateForm
    };
};
```

**사용 예시**:
```javascript
setup() {
    const { validateForm, validateEmail } = useFormValidation();

    const form = Vue.reactive({
        email: '',
        password: '',
        name: ''
    });

    const rules = {
        email: [
            { required: true, message: '이메일은 필수입니다.' },
            { validator: validateEmail, message: '유효한 이메일을 입력하세요.' }
        ],
        password: [
            { required: true, message: '비밀번호는 필수입니다.' },
            { min: 8, message: '비밀번호는 8자 이상이어야 합니다.' }
        ],
        name: [
            { required: true, message: '이름은 필수입니다.' },
            { max: 50, message: '이름은 50자 이하여야 합니다.' }
        ]
    };

    const handleSubmit = () => {
        const errors = validateForm(form, rules);
        if (Object.keys(errors).length === 0) {
            console.log('폼 검증 통과');
        } else {
            console.log('검증 실패:', errors);
        }
    };

    return { form, handleSubmit };
}
```

## 사용 가이드

1. **useApi**: API 호출 (GET, POST, PUT, DELETE)
   - 에러 처리 자동
   - 로딩 상태 관리

2. **useAuth**: 인증 관련 작업
   - 로그인/로그아웃
   - 토큰 갱신
   - 회원가입

3. **useFormValidation**: 폼 검증
   - 필드별 검증
   - 폼 전체 검증
   - 커스텀 검증

## 체크리스트

- [ ] useApi 구현 (request 메서드)
- [ ] useAuth 구현 (login, logout, refreshToken, register)
- [ ] useFormValidation 구현 (validateEmail, validatePassword, validatePhoneNumber, validateForm)
- [ ] Composable 파일 위치: `composables/` 디렉토리
- [ ] 에러 처리 자동
- [ ] 로딩 상태 관리
- [ ] 타입 안전성
- [ ] 테스트 케이스 작성
