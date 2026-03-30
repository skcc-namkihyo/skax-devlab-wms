---
description: "Vue 컴포넌트와 Element Plus UI 패턴 | Component patterns with Element Plus UI"
---

# fe-component

## 개요

Vue 3 Composition API 기반 컴포넌트와 Element Plus UI 패턴을 제공합니다. 기본 컴포넌트, 레이아웃, 폼, 테이블, 다이얼로그, 메시지 등을 포함합니다.

**사용 시점**: 새로운 UI 컴포넌트가 필요할 때

## 템플릿 / 패턴

### 기본 컴포넌트

```javascript
// components/common/UserCard.js
const { defineComponent, computed } = Vue;

export default defineComponent({
    name: 'UserCard',
    props: {
        user: {
            type: Object,
            required: true
        },
        isLoading: {
            type: Boolean,
            default: false
        }
    },
    emits: ['edit', 'delete'],
    template: `
        <el-card class="user-card">
            <template #header>
                <div class="card-header flex justify-between">
                    <span>{{ user.userName }}</span>
                    <span class="text-xs text-gray-500">{{ formatDate(user.createdAt) }}</span>
                </div>
            </template>

            <div class="space-y-2">
                <p><strong>이메일:</strong> {{ user.userEmail }}</p>
                <p><strong>상태:</strong>
                    <el-tag :type="user.isActive ? 'success' : 'danger'">
                        {{ user.isActive ? '활성' : '비활성' }}
                    </el-tag>
                </p>
            </div>

            <template #footer>
                <el-button type="primary" size="small" @click="$emit('edit')">수정</el-button>
                <el-button type="danger" size="small" @click="$emit('delete')">삭제</el-button>
            </template>
        </el-card>
    `,
    setup(props) {
        const formatDate = (date) => {
            return new Date(date).toLocaleDateString('ko-KR');
        };

        return { formatDate };
    }
});
```

### 레이아웃 컴포넌트

```javascript
// components/layout/PageHeader.js
const { defineComponent } = Vue;

export default defineComponent({
    name: 'PageHeader',
    props: {
        title: { type: String, required: true },
        breadcrumbs: { type: Array, default: () => [] }
    },
    template: `
        <div class="page-header flex justify-between items-center mb-5">
            <div>
                <el-breadcrumb separator="/">
                    <el-breadcrumb-item v-for="crumb in breadcrumbs" :key="crumb">
                        {{ crumb }}
                    </el-breadcrumb-item>
                </el-breadcrumb>
                <h1 class="text-2xl font-bold mt-2">{{ title }}</h1>
            </div>
            <el-button type="text" icon="Star">즐겨찾기</el-button>
        </div>
    `
});
```

### 폼 컴포넌트

```javascript
// components/common/UserForm.js
const { defineComponent, reactive, ref } = Vue;

export default defineComponent({
    name: 'UserForm',
    props: {
        user: { type: Object, default: () => ({}) },
        isLoading: { type: Boolean, default: false }
    },
    emits: ['submit', 'cancel'],
    template: `
        <el-form
            ref="formRef"
            :model="form"
            :rules="formRules"
            label-width="120px"
            @submit.prevent="handleSubmit"
        >
            <el-form-item label="이름" prop="userName">
                <el-input v-model="form.userName" placeholder="사용자 이름"></el-input>
            </el-form-item>

            <el-form-item label="이메일" prop="userEmail">
                <el-input v-model="form.userEmail" type="email" placeholder="이메일"></el-input>
            </el-form-item>

            <el-form-item label="활성상태">
                <el-switch v-model="form.isActive"></el-switch>
            </el-form-item>

            <el-form-item>
                <el-button type="primary" @click="handleSubmit" :loading="isLoading">저장</el-button>
                <el-button @click="$emit('cancel')">취소</el-button>
            </el-form-item>
        </el-form>
    `,
    setup(props, { emit }) {
        const form = reactive({
            userName: props.user.userName || '',
            userEmail: props.user.userEmail || '',
            isActive: props.user.isActive !== undefined ? props.user.isActive : true
        });

        const formRules = {
            userName: [
                { required: true, message: '이름은 필수입니다.' }
            ],
            userEmail: [
                { required: true, message: '이메일은 필수입니다.' },
                { type: 'email', message: '유효한 이메일을 입력하세요.' }
            ]
        };

        const handleSubmit = () => {
            emit('submit', form);
        };

        return { form, formRules, handleSubmit };
    }
});
```

### 검색 폼

```javascript
// components/layout/SearchForm.js
export default defineComponent({
    name: 'SearchForm',
    props: {
        filters: { type: Object, required: true }
    },
    emits: ['search', 'reset'],
    template: `
        <div class="search-form mb-5 p-5 bg-light">
            <el-form :model="filters" inline>
                <el-form-item label="이름">
                    <el-input v-model="filters.userName" placeholder="검색..."></el-input>
                </el-form-item>

                <el-form-item label="상태">
                    <el-select v-model="filters.isActive" placeholder="선택">
                        <el-option label="활성" :value="true"></el-option>
                        <el-option label="비활성" :value="false"></el-option>
                    </el-select>
                </el-form-item>

                <el-button type="primary" @click="$emit('search')">검색</el-button>
                <el-button @click="$emit('reset')">초기화</el-button>
            </el-form>
        </div>
    `
});
```

### 데이터 테이블

```javascript
// components/common/UserTable.js
export default defineComponent({
    name: 'UserTable',
    props: {
        data: { type: Array, required: true },
        loading: { type: Boolean, default: false }
    },
    emits: ['edit', 'delete', 'selection-change'],
    template: `
        <el-table
            :data="data"
            stripe
            border
            v-loading="loading"
            @selection-change="$emit('selection-change', $event)"
        >
            <el-table-column type="selection" width="50"></el-table-column>
            <el-table-column prop="userId" label="ID" width="100"></el-table-column>
            <el-table-column prop="userName" label="이름" min-width="150"></el-table-column>
            <el-table-column prop="userEmail" label="이메일" min-width="200"></el-table-column>
            <el-table-column label="상태" width="100">
                <template #default="{ row }">
                    <el-tag :type="row.isActive ? 'success' : 'danger'">
                        {{ row.isActive ? '활성' : '비활성' }}
                    </el-tag>
                </template>
            </el-table-column>
            <el-table-column label="작업" width="150" fixed="right">
                <template #default="{ row }">
                    <el-button type="primary" size="small" @click="$emit('edit', row)">수정</el-button>
                    <el-button type="danger" size="small" @click="$emit('delete', row)">삭제</el-button>
                </template>
            </el-table-column>
        </el-table>
    `
});
```

### 다이얼로그/모달

```javascript
// components/common/ConfirmDialog.js
export default defineComponent({
    name: 'ConfirmDialog',
    props: {
        visible: { type: Boolean, default: false },
        title: { type: String, required: true },
        content: { type: String, required: true }
    },
    emits: ['update:visible', 'confirm', 'cancel'],
    template: `
        <el-dialog
            :model-value="visible"
            :title="title"
            width="400px"
            @update:model-value="$emit('update:visible', $event)"
        >
            <div class="py-5">{{ content }}</div>
            <template #footer>
                <el-button @click="$emit('update:visible', false); $emit('cancel')">취소</el-button>
                <el-button type="primary" @click="$emit('confirm')">확인</el-button>
            </template>
        </el-dialog>
    `
});
```

### 메시지/알림

> 실제 `.js` 모듈에서는 `frontend.dev.mdc` 4절에 따라 파일 상단에 `const { ElMessage } = ElementPlus` 또는 `const { ElMessage, ElMessageBox } = ElementPlus` 를 둔 뒤 아래 API를 호출한다.

```javascript
// 성공 메시지
ElMessage.success('저장되었습니다.');

// 에러 메시지
ElMessage.error('오류가 발생했습니다.');

// 경고
ElMessage.warning('정말 삭제하시겠습니까?');

// 확인 다이얼로그
ElMessageBox.confirm('정말 삭제하시겠습니까?', '삭제 확인')
    .then(() => {
        // 삭제 처리
        ElMessage.success('삭제되었습니다.');
    })
    .catch(() => {
        // 취소
    });
```

## Element Plus UI 패턴

### 버튼 (Button)

```html
<el-button>기본</el-button>
<el-button type="primary">기본(파랑)</el-button>
<el-button type="success">성공(초록)</el-button>
<el-button type="danger">위험(빨강)</el-button>
<el-button type="warning">경고(주황)</el-button>
<el-button size="small">작은 버튼</el-button>
<el-button plain>투명 배경</el-button>
<el-button round>라운드</el-button>
```

### 입력 필드 (Input)

```html
<el-input v-model="text" placeholder="입력..."></el-input>
<el-input v-model="email" type="email" placeholder="이메일"></el-input>
<el-input v-model="password" type="password" placeholder="비밀번호"></el-input>
<el-input v-model="textarea" type="textarea" rows="4"></el-input>
```

### 선택 (Select)

```html
<el-select v-model="selected" placeholder="선택...">
    <el-option label="옵션1" value="1"></el-option>
    <el-option label="옵션2" value="2"></el-option>
</el-select>
```

### 스위치 (Switch)

```html
<el-switch v-model="isActive" active-text="활성" inactive-text="비활성"></el-switch>
```

### 태그 (Tag)

```html
<el-tag>기본</el-tag>
<el-tag type="success">성공</el-tag>
<el-tag type="danger">위험</el-tag>
<el-tag closable @close="handleClose">삭제 가능</el-tag>
```

### 페이지네이션 (Pagination)

```html
<el-pagination
    v-model:current-page="currentPage"
    :page-size="pageSize"
    :total="total"
    @current-change="fetchList"
></el-pagination>
```

## CSS 패턴

```css
/* 레이아웃 */
.app-layout {
    display: flex;
    flex-direction: column;
    height: 100vh;
}

.app-content {
    flex: 1;
    overflow-y: auto;
    padding: 20px;
    background: #ffffff;
}

/* 여백 */
.mb-4 { margin-bottom: 1rem; }
.mb-5 { margin-bottom: 1.25rem; }
.p-4 { padding: 1rem; }
.p-5 { padding: 1.25rem; }

/* 색상 */
.bg-light { background: #f5f7fa; }
.text-secondary { color: #909399; }

/* 폼 */
.form-container {
    max-width: 600px;
}
```

## 전역 에러 핸들러 패턴

> ⚠️ `app.js`에 반드시 구현해야 하는 에러 핸들러입니다.

### 전역 에러 캐치

```javascript
// app.js — 전역 에러 핸들러 (필수)
window.addEventListener('error', (event) => {
    console.error('[Global Error]', event.error);
    const appEl = document.getElementById('app');
    if (appEl && !appEl.__vue_app__) {
        appEl.innerHTML = `
            <div style="padding: 40px; text-align: center; color: #F56C6C;">
                <h2>오류가 발생했습니다</h2>
                <p>${event.message}</p>
                <p style="color: #909399; font-size: 12px;">브라우저 콘솔(F12)을 확인하세요.</p>
            </div>
        `;
    }
});
```

### Promise 거부 핸들러

```javascript
window.addEventListener('unhandledrejection', (event) => {
    console.error('[Unhandled Rejection]', event.reason);
});
```

### Vue/CDN 로드 확인 + 모듈 로드

```javascript
// app.js — Vue 로드 확인 및 모듈 초기화
if (typeof Vue === 'undefined') {
    document.getElementById('app').innerHTML = `
        <div style="padding: 40px; text-align: center; color: #E6A23C;">
            <h2>라이브러리 로드 실패</h2>
            <p>Vue CDN 로드에 실패했습니다. 네트워크 연결을 확인하세요.</p>
        </div>
    `;
} else {
    Promise.all([
        import('./store.js'),
        import('./router.js')
    ]).then(([storeModule, routerModule]) => {
        // Vue 앱 마운트
        const app = Vue.createApp(App);
        app.use(routerModule.default);
        app.use(ElementPlus);
        app.mount('#app');
    }).catch((error) => {
        console.error('[Module Load Error]', error);
        document.getElementById('app').innerHTML = `
            <div style="padding: 40px; text-align: center; color: #F56C6C;">
                <h2>모듈 로드 실패</h2>
                <p>${error.message}</p>
                <pre style="text-align: left; background: #f5f5f5; padding: 10px; margin-top: 10px; font-size: 12px;">${error.stack}</pre>
            </div>
        `;
    });
}
```

> 모든 에러 핸들러는 콘솔 로그와 함께 사용자에게 명확한 안내 메시지를 제공합니다.

## 사이드바 Flexbox 레이아웃

### 레이아웃 구조

```
┌─────────────────────────────┐
│  사이드바 헤더 (flex-shrink: 0)  │
├─────────────────────────────┤
│                             │
│  메뉴 영역 (flex: 1)         │
│  overflow-y: auto           │
│                             │
├─────────────────────────────┤
│  사용자 정보 (flex-shrink: 0)   │
│  + 로그아웃 버튼              │
└─────────────────────────────┘
```

### CSS 구현

```css
.app-sidebar {
    display: flex;
    flex-direction: column;
    height: 100vh;
    background: #304156;
    transition: width 0.3s;
}

.sidebar-header {
    flex-shrink: 0;
    padding: 20px;
    text-align: center;
    border-bottom: 1px solid #1f2d3d;
}

.sidebar-menu {
    flex: 1;
    overflow-y: auto;
}

.sidebar-footer {
    flex-shrink: 0;
    padding: 12px;
    background: #263445;
    border-top: 1px solid #1f2d3d;
}
```

### 사이드바 하단 사용자 정보 패턴

```javascript
// components/layout/SidebarFooter.js
export default defineComponent({
    name: 'SidebarFooter',
    props: {
        user: { type: Object, required: true },
        collapsed: { type: Boolean, default: false }
    },
    emits: ['logout'],
    template: `
        <div class="sidebar-footer">
            <div v-if="!collapsed" class="user-info">
                <div style="font-weight: bold; color: #fff;">{{ user.name }}</div>
                <div style="font-size: 12px; color: #909399;">{{ user.email }}</div>
            </div>
            <div v-else class="text-center">
                <el-avatar :size="32">{{ user.name?.charAt(0) }}</el-avatar>
            </div>
            <el-button
                type="text"
                style="color: #909399; width: 100%; margin-top: 8px;"
                :title="'로그아웃'"
                @click="handleLogout"
            >
                {{ collapsed ? 'OUT' : '로그아웃' }}
            </el-button>
        </div>
    `,
    setup(props, { emit }) {
        const handleLogout = () => {
            ElMessageBox.confirm('정말 로그아웃 하시겠습니까?', '로그아웃 확인')
                .then(() => emit('logout'))
                .catch(() => {});
        };
        return { handleLogout };
    }
});
```

### 사이드바 접기/펼치기 상태 관리

```javascript
// composables/useSidebar.js
export const useSidebar = () => {
    const collapsed = Vue.ref(false);
    const activeMenu = Vue.ref('');

    const toggle = () => { collapsed.value = !collapsed.value; };

    const sidebarWidth = Vue.computed(() =>
        collapsed.value ? '64px' : '240px'
    );

    return { collapsed, activeMenu, toggle, sidebarWidth };
};
```

## 사용 가이드

1. **컴포넌트 생성**: `components/[type]/[Name].js`
2. **Props 정의**: 필수/선택 props 명시
3. **Emits 정의**: 이벤트 명시
4. **Template**: Element Plus 컴포넌트 사용
5. **Setup**: 로직 구현
6. **스타일**: Tailwind CSS + 커스텀 CSS

## 체크리스트

- [ ] 컴포넌트 이름 (PascalCase)
- [ ] Props 타입 지정
- [ ] Emits 정의
- [ ] JavaDoc 주석
- [ ] Element Plus 컴포넌트만 사용
- [ ] 반응형 디자인
- [ ] 접근성 고려
