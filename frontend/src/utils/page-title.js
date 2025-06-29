import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'

// 全局页面标题状态
const pageTitle = ref('')
const customTitle = ref('')

// 页面标题映射
const pageTitleMap = {
  '/': '', // 首页不显示额外标题，只显示 AI Gallery
  '/categories': '分类浏览',
  '/departments': '部门作品',
  '/daily': '每日更新',
  '/timeline': '时间线',
  '/popular': '魅力榜',
  '/favorites': '收藏榜',
  '/downloads': '下载榜',
  '/search': '搜索结果',
  '/upload': '作品上传',
  '/login': '用户登录',
  '/register': '用户注册',
  '/profile': '个人主页',
  '/admin': '管理后台'
}

// 管理后台页面标题映射
const adminPageTitleMap = {
  '/admin': '仪表盘',
  '/admin/dashboard': '仪表盘',
  '/admin/users': '用户管理',
  '/admin/departments': '部门管理',
  '/admin/galleries': '图集管理',
  '/admin/topics': '专题管理',
  '/admin/categories': '分类管理',
  '/admin/comments': '评论管理',
  '/admin/settings': '系统设置'
}

// 分类名称映射
const categoryNames = {
  1: '风景摄影',
  2: '人像摄影',
  3: '街拍摄影',
  4: '建筑摄影',
  5: '静物摄影',
  6: '微距摄影',
  7: '夜景摄影',
  8: '黑白摄影',
  9: '创意摄影',
  10: '纪实摄影'
}

// 部门名称映射
const departmentNames = {
  1: '摄影部',
  2: '设计部',
  3: '技术部',
  4: '运营部',
  5: '市场部'
}

export function usePageTitle(siteName = 'AI Gallery') {
  const route = useRoute()

  // 计算当前页面标题
  const currentTitle = computed(() => {
    if (customTitle.value) {
      return customTitle.value
    }

    const path = route.path
    
    // 管理后台页面标题处理
    if (path.startsWith('/admin')) {
      const adminTitle = adminPageTitleMap[path] || '管理后台'
      return `${adminTitle} - 管理后台 - ${siteName}`
    }

    let title = pageTitleMap[path] || siteName

    // 根据查询参数动态调整标题
    if (path === '/categories' && route.query.category) {
      const categoryId = parseInt(route.query.category)
      const categoryName = categoryNames[categoryId]
      if (categoryName) {
        title = `${categoryName} - 分类浏览`
      }
    }

    if (path === '/departments' && route.query.department) {
      const departmentId = parseInt(route.query.department)
      const departmentName = departmentNames[departmentId]
      if (departmentName) {
        title = `${departmentName} - 部门作品`
      }
    }

    if (path === '/search' && route.query.q) {
      title = `"${route.query.q}" - 搜索结果`
    }

    if (path.startsWith('/profile/') && route.params.username) {
      title = `${route.params.username} - 个人主页`
    }

    if (path.startsWith('/gallery/') && route.params.id) {
      title = `图集详情 - ${route.params.id}`
    }

    if (path.startsWith('/image/') && route.params.id) {
      title = `图片详情 - ${route.params.id}`
    }

    // 非首页且非管理后台页面，添加站点名称
    if (title && title !== siteName && !path.startsWith('/admin')) {
      title = `${title} - ${siteName}`
    }

    return title || siteName
  })

  // 设置自定义标题
  function setTitle(title) {
    customTitle.value = title
    pageTitle.value = title
  }

  // 清除自定义标题，使用默认标题
  function clearCustomTitle() {
    customTitle.value = ''
    pageTitle.value = currentTitle.value
  }

  // 更新分类名称映射
  function updateCategoryNames(categories) {
    categories.forEach(category => {
      categoryNames[category.id] = category.name
    })
  }

  // 更新部门名称映射
  function updateDepartmentNames(departments) {
    departments.forEach(department => {
      departmentNames[department.id] = department.name
    })
  }

  return {
    currentTitle,
    pageTitle,
    setTitle,
    clearCustomTitle,
    updateCategoryNames,
    updateDepartmentNames
  }
} 