<template>
  <div class="legal-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>用户协议</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">用户协议</h1>
          <p class="page-subtitle">OurGallery 图片分享平台用户协议</p>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <n-card class="content-card">
          <div class="legal-content">
            <h2>1. 服务概述</h2>
            <p>OurGallery 是一个面向企业内部使用的图片分享平台，旨在提供内部资源共享服务。本平台允许用户上传、分享和管理图片资源，促进企业内部的信息交流和知识共享。</p>

            <h2>2. 用户权利与义务</h2>
            <h3>2.1 用户权利</h3>
            <ul>
              <li>在获得授权的情况下，使用平台提供的图片分享和管理功能</li>
              <li>上传具有合法版权的图片资源</li>
              <li>对个人上传的内容进行管理和删除</li>
              <li>享受平台提供的技术支持和服务</li>
            </ul>

            <h3>2.2 用户义务</h3>
            <ul>
              <li>遵守国家相关法律法规和企业内部规定</li>
              <li>确保上传的图片内容合法、合规，不侵犯他人知识产权</li>
              <li>不得上传含有敏感信息、商业机密或违反企业政策的内容</li>
              <li>妥善保管个人账户信息，不得将账户借给他人使用</li>
              <li>不得利用平台进行任何违法或不当活动</li>
            </ul>

            <h2>3. 内容管理</h2>
            <h3>3.1 上传内容</h3>
            <p>用户上传的图片内容应当：</p>
            <ul>
              <li>具有合法的版权或使用授权</li>
              <li>符合企业内部的资源分享政策</li>
              <li>不包含敏感或机密信息</li>
              <li>符合平台的技术规范要求</li>
            </ul>

            <h3>3.2 内容审核</h3>
            <p>平台管理员有权对用户上传的内容进行审核，对于不符合要求的内容，平台有权进行删除或限制访问。</p>

            <h2>4. 知识产权</h2>
            <h3>4.1 平台软件版权</h3>
            <p>OurGallery 软件系统的版权归开发者所有，用户需要获得授权方可使用。未经授权，不得对软件进行复制、修改、分发或商业使用。</p>

            <h3>4.2 用户内容版权</h3>
            <p>用户上传的图片内容版权归原权利人所有，平台仅提供存储和分享服务。用户应当确保拥有上传内容的合法使用权。</p>

            <h3>4.3 对外使用限制</h3>
            <p>如需将平台内容对外使用，运营方必须具有相关资源的版权或授权。未经授权，不得将平台内容用于商业用途或对外传播。</p>

            <h2>5. 服务限制</h2>
            <ul>
              <li>平台仅供企业内部使用，不得用于商业运营</li>
              <li>用户不得利用平台进行任何商业活动</li>
              <li>平台有权根据企业需求调整服务内容和功能</li>
              <li>在特殊情况下，平台可能暂停或终止服务</li>
            </ul>

            <h2>6. 免责声明</h2>
            <ul>
              <li>平台不对用户上传内容的合法性承担责任</li>
              <li>因用户违规使用造成的损失由用户自行承担</li>
              <li>平台不保证服务的连续性和无故障运行</li>
              <li>因不可抗力导致的服务中断，平台不承担责任</li>
            </ul>

            <h2>7. 协议修改</h2>
            <p>平台有权根据法律法规变化或业务需要修改本协议。修改后的协议将在平台内公布，继续使用平台服务即表示接受修改后的协议。</p>

            <h2>8. 联系方式</h2>
            <p>如对本协议有任何疑问，请联系平台管理员或发送邮件至：admin@ourgallery.com</p>

            <div class="agreement-footer">
              <p><strong>最后更新时间：</strong>2025年7月26日</p>
              <p><strong>协议版本：</strong>v1.0</p>
            </div>
          </div>
        </n-card>
      </div>
    </div>

    <!-- 统一底部组件 -->
    <AppFooter theme-color="#667eea" />
  </div>
</template>

<script setup>
import AppFooter from '@/components/AppFooter.vue';
import { NBreadcrumb, NBreadcrumbItem, NCard } from 'naive-ui';
</script>

<style scoped>
.legal-page {
  padding-top: 64px;
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-bottom: 1px solid #e5e7eb;
  padding: 24px 0;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
}

.breadcrumb {
  margin-bottom: 16px;
}

.breadcrumb :deep(.n-breadcrumb-item__link) {
  color: rgba(255, 255, 255, 0.8);
}

.breadcrumb :deep(.n-breadcrumb-item__link:hover) {
  color: white;
}

.breadcrumb :deep(.n-breadcrumb-item__separator) {
  color: rgba(255, 255, 255, 0.6);
}

.page-title-section {
  text-align: center;
  margin-bottom: 24px;
}

.page-title {
  font-size: 32px;
  font-weight: bold;
  color: white;
  margin: 0 0 8px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.page-subtitle {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
}

/* 主要内容区域 */
.main-content {
  padding: 40px 0;
}

.content-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.legal-content {
  line-height: 1.8;
  color: #374151;
}

.legal-content h2 {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin: 32px 0 16px 0;
  padding-bottom: 8px;
  border-bottom: 2px solid #e5e7eb;
}

.legal-content h3 {
  font-size: 20px;
  font-weight: 600;
  color: #374151;
  margin: 24px 0 12px 0;
}

.legal-content p {
  margin: 16px 0;
  font-size: 16px;
}

.legal-content ul {
  margin: 16px 0;
  padding-left: 24px;
}

.legal-content li {
  margin: 8px 0;
  font-size: 16px;
}

.agreement-footer {
  margin-top: 48px;
  padding-top: 24px;
  border-top: 1px solid #e5e7eb;
  text-align: center;
  color: #6b7280;
}

.agreement-footer p {
  margin: 8px 0;
  font-size: 14px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }

  .page-title {
    font-size: 24px;
  }

  .page-subtitle {
    font-size: 14px;
  }

  .page-header {
    padding: 16px 0;
  }

  .main-content {
    padding: 20px 0;
  }

  .legal-content h2 {
    font-size: 20px;
    margin: 24px 0 12px 0;
  }

  .legal-content h3 {
    font-size: 18px;
    margin: 20px 0 10px 0;
  }

  .legal-content p,
  .legal-content li {
    font-size: 15px;
  }
}

@media (max-width: 480px) {
  .page-title {
    font-size: 20px;
  }

  .page-subtitle {
    font-size: 13px;
  }

  .container {
    padding: 0 12px;
  }

  .main-content {
    padding: 12px 0;
  }

  .legal-content h2 {
    font-size: 18px;
  }

  .legal-content h3 {
    font-size: 16px;
  }

  .legal-content p,
  .legal-content li {
    font-size: 14px;
  }
}
</style> 