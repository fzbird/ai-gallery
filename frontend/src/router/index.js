import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

import HomeView from '../views/HomeView.vue'
import LoginView from '../views/LoginView.vue'
import RegisterView from '../views/RegisterView.vue'
import UploadView from '../views/UploadView.vue'
import GalleryUploadView from '../views/GalleryUploadView.vue'
import ImageView from '../views/ImageView.vue'
import GalleryView from '../views/GalleryView.vue'
import ProfileView from '../views/ProfileView.vue'
import SearchView from '../views/SearchView.vue'
import AdminLayout from '../layouts/AdminLayout.vue'
import AdminDashboard from '../views/admin/AdminDashboard.vue'
import AdminUsers from '../views/admin/AdminUsers.vue'
import AdminImages from '../views/admin/AdminImages.vue'
import AdminCategories from '../views/admin/AdminCategories.vue'
import AdminSettings from '../views/admin/AdminSettings.vue'
import AdminDepartments from '../views/admin/AdminDepartments.vue'
import AdminTopics from '../views/admin/AdminTopics.vue'
import AdminComments from '../views/admin/AdminComments.vue'

// 新增页面导入
import CategoryView from '../views/CategoryView.vue'
import CategoriesView from '../views/CategoriesView.vue'
import DepartmentView from '../views/DepartmentView.vue'
import DepartmentsView from '../views/DepartmentsView.vue'
import DailyView from '../views/DailyView.vue'
import TimelineView from '../views/TimelineView.vue'
import PopularView from '../views/PopularView.vue'
import FavoritesView from '../views/FavoritesView.vue'
import DownloadsView from '../views/DownloadsView.vue'
import TopicsView from '../views/TopicsView.vue'
import TopicView from '../views/TopicView.vue'
import UsersView from '../views/UsersView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/categories',
      name: 'categories',
      component: CategoriesView
    },
    {
      path: '/categories/:id',
      name: 'category',
      component: CategoryView,
      props: true
    },
    {
      path: '/departments',
      name: 'departments',
      component: DepartmentsView
    },
    {
      path: '/departments/:id',
      name: 'department',
      component: DepartmentView,
      props: true
    },
    {
      path: '/daily',
      name: 'daily',
      component: DailyView
    },
    {
      path: '/timeline',
      name: 'timeline',
      component: TimelineView
    },
    {
      path: '/popular',
      name: 'popular',
      component: PopularView
    },
    {
      path: '/favorites',
      name: 'favorites',
      component: FavoritesView
    },
    {
      path: '/downloads',
      name: 'downloads',
      component: DownloadsView
    },
    {
      path: '/login',
      name: 'login',
      component: LoginView
    },
    {
      path: '/register',
      name: 'register',
      component: RegisterView
    },
    {
      path: '/upload',
      name: 'upload',
      component: UploadView,
      meta: { requiresAuth: true }
    },
    {
      path: '/gallery/upload',
      name: 'gallery-upload',
      component: GalleryUploadView,
      meta: { requiresAuth: true }
    },
    {
      path: '/images/:id',
      name: 'image-detail',
      component: ImageView,
      props: true
    },
    {
      path: '/galleries/:id',
      name: 'gallery',
      component: GalleryView,
      props: true
    },
    {
      path: '/users',
      name: 'users',
      component: UsersView
    },
    {
      path: '/users/:username',
      name: 'profile',
      component: ProfileView,
      props: true
    },
    {
      path: '/search',
      name: 'search',
      component: SearchView,
      props: (route) => ({ query: route.query.q })
    },
    {
      path: '/topics',
      name: 'topics',
      component: TopicsView
    },
    {
      path: '/topics/:id',
      name: 'topic',
      component: TopicView
    },
    {
      path: '/admin',
      component: AdminLayout,
      meta: { requiresAdmin: true, title: '管理后台' },
      children: [
        {
          path: '',
          name: 'admin-dashboard',
          component: AdminDashboard,
          meta: { title: '仪表盘' }
        },
        {
          path: 'users',
          name: 'admin-users',
          component: AdminUsers,
          meta: { title: '用户管理' }
        },
        {
          path: 'galleries',
          name: 'admin-galleries',
          component: AdminImages,
          meta: { title: '图集管理' }
        },
        {
          path: 'topics',
          name: 'admin-topics',
          component: AdminTopics,
          meta: { title: '专题管理' }
        },
        {
          path: 'categories',
          name: 'admin-categories',
          component: AdminCategories,
          meta: { title: '分类管理' }
        },
        {
          path: 'comments',
          name: 'admin-comments',
          component: AdminComments,
          meta: { title: '评论管理' }
        },
        {
          path: 'settings',
          name: 'admin-settings',
          component: AdminSettings,
          meta: { title: '系统设置' }
        },
        {
          path: 'departments',
          name: 'admin-departments',
          component: AdminDepartments,
          meta: { title: '部门管理' }
        }
      ]
    }
  ]
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  const { isAuthenticated, user } = authStore

  if (to.meta.requiresAuth && !isAuthenticated) {
    next({ name: 'login' })
  } else if (to.meta.requiresAdmin && (!isAuthenticated || !user?.is_superuser)) {
    // Redirect to home if not an admin
    next({ name: 'home' })
  }
  else {
    next()
  }
})

export default router 