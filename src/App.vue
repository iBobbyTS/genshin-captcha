<script setup>
import { ref, computed, onMounted } from 'vue'
import chars from './char.json'
// Build an index of local image assets for runtime resolution
// NOTE: This indexes common image extensions under src (relative to this file)
const imageModules = import.meta.glob('./**/*.{png,jpg,jpeg,webp,gif,svg}', { eager: true })
const assetIndex = new Map()
for (const [modPath, mod] of Object.entries(imageModules)) {
  // modPath examples: './images/Nahida1.png' or './char/nahida/6.jpg'
  const url = mod && mod.default ? mod.default : ''
  const noDot = modPath.startsWith('./') ? modPath.slice(2) : modPath
  const noExt = noDot.replace(/\.[^.]+$/, '')
  // index multiple keys for flexible lookup
  assetIndex.set(modPath, url)
  assetIndex.set(noDot, url)
  assetIndex.set(noExt, url)
}

// Use JSON data as runtime metadata to initialize grid items
const charData = chars
const currentCharKey = 'nahida'
const images = ref(Array.from({ length: 9 }, (_, idx) => {
  const id = idx + 1
  return {
    id,
    selected: false,
    type: id === 5 ? 'cake' : currentCharKey,
    src: '', // no image for now
    placeholder: ''
  }
}))

// Dropdown: selected character and change handler
const selectedChar = ref((chars && Array.isArray(chars.char) && chars.char[0]) ? chars.char[0] : '')
const onCharSelected = (name) => {
  // helpers
  const safeKeys = (obj) => obj ? Object.keys(obj) : []
  const shuffle = (arr) => {
    const out = arr.slice()
    for (let i = out.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      const tmp = out[i]
      out[i] = out[j]
      out[j] = tmp
    }
    return out
  }
  const sampleN = (arr, n) => shuffle(arr).slice(0, Math.max(0, n))
  const pickOne = (arr) => (arr && arr.length > 0) ? arr[0] : undefined

  const detail = (chars && chars.char_detail) ? chars.char_detail[name] : undefined
  // 1) 从 char_src 里取出 8 个 key
  const charSrcKeysAll = safeKeys(detail && detail.char_src)
  const charSrcKeys8 = sampleN(charSrcKeysAll, 8)

  // 2) 遍历 cake_list，进入 cake_detail[cakeName]，获取其 key 列表并各取一个
  const cakeList = (detail && Array.isArray(detail.cake_list)) ? detail.cake_list : []
  const cakePicked = cakeList.map((cakeName) => {
    const cakeDetail = (chars && chars.cake_detail) ? chars.cake_detail[cakeName] : undefined
    const cakeKeys = safeKeys(cakeDetail)
    return { cakeName, pickedKey: pickOne(cakeKeys) }
  })

  // 3) 转换为路径并合并、随机
  const charPaths = charSrcKeys8.map(k => `char/${name}/${k}`)
  const cakePaths = cakePicked
    .filter(x => x.pickedKey !== undefined && x.pickedKey !== null)
    .map(x => `cake/${x.cakeName}/${x.pickedKey}`)
  const merged = [...charPaths, ...cakePaths]
  const shuffled = sampleN(merged, merged.length)

  // 4) 解析路径 -> 本地打包后的 URL，并填充到 9 个占位中
  const resolveUrl = (path) => {
    if (!path) return ''
    // Try exact, and with common prefixes and without extension
    // Our strings look like 'char/xxx/key' or 'cake/xxx/name.ext'
    const candidates = []
    candidates.push(path) // as-is
    candidates.push(`./${path}`)
    candidates.push(`./images/${path}`)
    // also try without extension if provided
    const noExt = path.replace(/\.[^.]+$/, '')
    candidates.push(noExt)
    candidates.push(`./${noExt}`)
    candidates.push(`./images/${noExt}`)
    for (const key of candidates) {
      const hit = assetIndex.get(key)
      if (hit) return hit
    }
    return ''
  }

  const next = images.value.map((item, idx) => {
    const p = shuffled[idx]
    const url = p ? resolveUrl(p) : ''
    const type = p ? (p.startsWith('cake/') ? 'cake' : name) : item.type
    return {
      ...item,
      selected: false,
      type,
      src: url || '',
      placeholder: p || ''
    }
  })
  images.value = next
}

// Title computed from selected character's cake_name
const selectedCakeName = computed(() => {
  const detail = chars && chars.char_detail && selectedChar.value ? chars.char_detail[selectedChar.value] : null
  return (detail && detail.cake_name) ? detail.cake_name : '萌小蛋糕'
})

// Trigger initial selection on mount
onMounted(() => {
  if (selectedChar.value) {
    onCharSelected(selectedChar.value)
  }
})

// 切换图片选中状态
const toggleImage = (id) => {
  const image = images.value.find(img => img.id === id)
  if (image) {
    image.selected = !image.selected
  }
}

// 验证按钮点击事件
const handleVerify = () => {
  // Success when: all non-cake are selected AND no cake is selected
  const allCharSelected = images.value.filter(img => img.type !== 'cake').every(img => img.selected)
  const anyCakeSelected = images.value.some(img => img.type === 'cake' && img.selected)

  if (allCharSelected && !anyCakeSelected) {
    showNotification({
      title: '🎉验证成功！🎉',
      message: '验证成功！\nCiallo～(∠・ω< )⌒☆'
    });
  } else {
    showNotification({
      title: '❌验证失败❌',
      message: '请选择正确的图片！'
    });
  }
}

// 信息图标点击事件
const handleInfoClick = () => {
  showNotification({
    title: '🍀说明🍀',
    message: '请选择世界上最萌的小蛋糕！完成后点击“验证”按钮。\nCiallo～(∠・ω< )⌒☆'
  });
}

// 通知相关状态和方法
const notification = ref({
  visible: false,
  title: '',
  message: '',
  animationType: ''
});

// 可用的动画效果
const animationTypes = ['fade', 'bounce', 'slide-up', 'slide-down', 'slide-left', 'slide-right', 'zoom', 'rotate'];

// 获取随机动画效果
const getRandomAnimation = () => {
  return animationTypes[Math.floor(Math.random() * animationTypes.length)];
};

// 显示通知的方法
const showNotification = (options) => {
  // 先隐藏通知（如果正在显示）
  notification.value.visible = false;
  
  // 短暂延迟后显示新通知，确保动画能够重新触发
  setTimeout(() => {
    notification.value = {
      visible: true,
      title: options.title || '通知',
      message: options.message || '',
      animationType: getRandomAnimation()
    };
  }, 10);
};

// 关闭通知的方法
const closeNotification = () => {
  // 添加淡出动画效果
  const container = document.querySelector('.notification-container');
  if (container) {
    container.style.opacity = '0';
    container.style.transform = 'scale(0.9)';
  }
  
  // 延迟后完全隐藏，让动画有足够时间播放
  setTimeout(() => {
    notification.value.visible = false;
  }, 300);
};

// 点击空白处关闭通知
const handleOverlayClick = (event) => {
  if (event.target.classList.contains('notification-overlay')) {
    closeNotification();
  }
};
</script>

<template>
  <div class="captcha-container">
    <!-- 左上角下拉框 -->
    <div class="toolbar">
      <select
        v-if="Array.isArray(chars.char)"
        v-model="selectedChar"
        @change="onCharSelected(selectedChar)"
      >
        <option v-for="c in chars.char" :key="c" :value="c">
          {{ (chars.char_detail && chars.char_detail[c] && chars.char_detail[c].name) ? chars.char_detail[c].name : c }}
        </option>
      </select>
    </div>
    <!-- 标题栏 -->
    <div class="header">
      <h3>选择所有包含</h3>
      <h2>世界上最{{ selectedCakeName }}</h2>
      <p>的图片，点按后请点击“ 验证 ”</p>
    </div>

    <!-- 图片网格 -->
    <div class="image-grid">
      <div 
          v-for="image in images" 
          :key="image.id" 
          class="image-item" 
          :class="{ 'selected': image.selected }"
          @click="toggleImage(image.id)"
        >
          <!-- 显示实际图片（若无图片则显示占位） -->
          <img v-if="image.src" :src="image.src" :alt="image.type === 'cake' ? '蛋糕' : '角色'" class="image-content" draggable="false">
          <div v-else class="image-placeholder">{{ image.placeholder || 'No Image' }}</div>
          <!-- 选中状态的对勾 -->
          <div v-if="image.selected" class="checkmark">
            <svg xmlns="http://www.w3.org/2000/svg" height="32px" viewBox="0 -960 960 960" width="32px" fill="#0079CD"><path d="m424-296 282-282-56-56-226 226-114-114-56 56 170 170Zm56 216q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Z"/></svg>
          </div>
        </div>
    </div>

    <!-- 底部区域 -->
    <div class="footer">
      <div style="display: flex; align-items: center; gap: 10px;">
        <div class="info-icon">
          <svg @click="handleInfoClick" xmlns="http://www.w3.org/2000/svg" height="32px" viewBox="0 -960 960 960" width="32px" fill="#1f1f1f"><path d="M440-280h80v-240h-80v240Zm40-320q17 0 28.5-11.5T520-640q0-17-11.5-28.5T480-680q-17 0-28.5 11.5T440-640q0 17 11.5 28.5T480-600Zm0 520q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Zm0-80q134 0 227-93t93-227q0-134-93-227t-227-93q-134 0-227 93t-93 227q0 134 93 227t227 93Zm0-320Z"/></svg>
        </div>
        <a href="https://github.com/iBobbyTS/genshin-captcha" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; justify-content: center; cursor: pointer;">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="32px" height="32px" fill="#1f1f1f"><title>github</title><path d="M12,2A10,10 0 0,0 2,12C2,16.42 4.87,20.17 8.84,21.5C9.34,21.58 9.5,21.27 9.5,21C9.5,20.77 9.5,20.14 9.5,19.31C6.73,19.91 6.14,17.97 6.14,17.97C5.68,16.81 5.03,16.5 5.03,16.5C4.12,15.88 5.1,15.9 5.1,15.9C6.1,15.97 6.63,16.93 6.63,16.93C7.5,18.45 8.97,18 9.54,17.76C9.63,17.11 9.89,16.67 10.17,16.42C7.95,16.17 5.62,15.31 5.62,11.5C5.62,10.39 6,9.5 6.65,8.79C6.55,8.54 6.2,7.5 6.75,6.15C6.75,6.15 7.59,5.88 9.5,7.17C10.29,6.95 11.15,6.84 12,6.84C12.85,6.84 13.71,6.95 14.5,7.17C16.41,5.88 17.25,6.15 17.25,6.15C17.8,7.5 17.45,8.54 17.35,8.79C18,9.5 18.38,10.39 18.38,11.5C18.38,15.32 16.04,16.16 13.81,16.41C14.17,16.72 14.5,17.33 14.5,18.26C14.5,19.6 14.5,20.68 14.5,21C14.5,21.27 14.66,21.59 15.17,21.5C19.14,20.16 22,16.42 22,12A10,10 0 0,0 12,2Z"/></svg>
        </a>
      </div>
      <button class="verify-button" @click="handleVerify">验证</button>
    </div>
  </div>
  
  <!-- 通知组件 -->
  <div 
    v-if="notification.visible" 
    class="notification-overlay"
    @click="handleOverlayClick"
  >
    <div 
      class="notification-container" 
      :class="notification.animationType"
    >
      <!-- 通知标题栏 -->
      <div class="notification-header">
        <div class="terminal-dots">
          <div class="dot red"></div>
          <div class="dot yellow"></div>
          <div class="dot green"></div>
        </div>
        <h3 class="notification-title">{{ notification.title }}</h3>
      </div>
      
      <!-- 通知内容 -->
      <div class="notification-body">
        <p class="notification-message">{{ notification.message }}</p>
      </div>
      
      <!-- 确认按钮 -->
      <div class="notification-footer">
        <button class="notification-button" @click="closeNotification">确定</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 通知组件样式 */
.notification-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.3);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
  animation: fadeIn 0.3s ease-out;
}

.notification-container {
  background-color: rgba(152, 251, 152, 0.9); /* 草绿色半透明 */
  border: 1px solid #4ade80;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  width: 400px;
  max-width: 90%;
  overflow: hidden;
  font-family: 'SF Mono', Monaco, 'Cascadia Code', monospace;
  transition: all 0.3s ease-out; /* 淡出动画过渡效果 */
}

/* 动画效果 - 渐入渐出 */
.notification-container.fade {
  animation: fadeIn 0.5s ease-out;
}

/* 动画效果 - 弹入弹出 */
.notification-container.bounce {
  animation: bounceIn 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
}

/* 动画效果 - 从上滑入 */
.notification-container.slide-up {
  animation: slideInFromTop 0.5s ease-out;
}

/* 动画效果 - 从下滑入 */
.notification-container.slide-down {
  animation: slideInFromBottom 0.5s ease-out;
}

/* 动画效果 - 从左滑入 */
.notification-container.slide-left {
  animation: slideInFromLeft 0.5s ease-out;
}

/* 动画效果 - 从右滑入 */
.notification-container.slide-right {
  animation: slideInFromRight 0.5s ease-out;
}

/* 动画效果 - 缩放 */
.notification-container.zoom {
  animation: zoomIn 0.5s ease-out;
}

/* 动画效果 - 旋转 */
.notification-container.rotate {
  animation: rotateIn 0.6s ease-out;
}

/* 动画关键帧定义 */
@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes bounceIn {
  0% {
    transform: scale(0.3);
    opacity: 0;
  }
  50% {
    transform: scale(1.05);
    opacity: 0.8;
  }
  70% {
    transform: scale(0.9);
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

@keyframes slideInFromTop {
  from {
    transform: translateY(-100px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

@keyframes slideInFromBottom {
  from {
    transform: translateY(100px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

@keyframes slideInFromLeft {
  from {
    transform: translateX(-100px);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes slideInFromRight {
  from {
    transform: translateX(100px);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes zoomIn {
  from {
    transform: scale(0.5);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

@keyframes rotateIn {
  from {
    transform: rotate(-30deg) scale(0.5);
    opacity: 0;
  }
  to {
    transform: rotate(0deg) scale(1);
    opacity: 1;
  }
}

/* Mac OS 终端风格标题栏 */
.notification-header {
  background-color: rgba(107, 174, 123, 0.5);
  padding: 10px;
  display: flex;
  align-items: center;
  border-bottom: 1px solid #4ade80;
}

.terminal-dots {
  display: flex;
  gap: 6px;
  margin-right: 12px;
}

.dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.dot.red {
  background-color: #ff5f56;
}

.dot.yellow {
  background-color: #ffbd2e;
}

.dot.green {
  background-color: #27c93f;
}

.notification-title {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
  color: #1e3a8a;
  flex: 1;
}

/* 通知内容样式 */
.notification-body {
  padding: 20px;
  background-color: rgba(174, 240, 178, 0.8);
}

.notification-message {
  margin: 0;
  font-size: 16px;
  line-height: 1.6;
  color: #1e3a8a;
  white-space: pre-line;
}

/* 底部按钮样式 */
.notification-footer {
  padding: 15px 20px;
  background-color: rgba(152, 251, 152, 0.7);
  text-align: right;
  border-top: 1px solid #4ade80;
}

.notification-button {
  background-color: #22c55e;
  color: white;
  border: none;
  padding: 8px 20px;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.notification-button:hover {
  background-color: #16a34a;
}

.captcha-container {
  max-width: 400px;
  margin: 0 auto;
  padding: 20px;
  font-family: Arial, sans-serif;
  background-color: #DCDCDD;
  border-radius: 8px;
}

.toolbar {
  display: flex;
  justify-content: flex-start;
  margin-bottom: 12px;
}

.header {
  background-color: #1976d2;
  color: white;
  padding: 20px;
  border-radius: 8px;
  text-align: left;
  margin-bottom: 20px;
}

.header h2 {
  margin: 5px 0;
  font-size: 20px;
}

.header h3, .header p {
  margin: 5px 0;
  font-size: 16px;
  font-weight: normal;
}

.image-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-bottom: 20px;
}
/** 动画时间0.2s */
.image-item {
  position: relative;
  aspect-ratio: 1;
  border: 1px solid #ddd;
  border-radius: 4px;
  cursor: pointer;
  background-color: #f5f5f5;
  transition: all 0.2s ease;
}

.image-item:hover {
  border-color: #1976d2;
}
/** 选中时候的缩放 */
.image-item.selected {
  transform: scale(0.88);
  border-color: #1976d2;
}

.image-content {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  border-radius: 4px;
}

.image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #6b7280;
  font-size: 14px;
  background: #f0f0f0;
  border-radius: 4px;
}

.checkmark {
  position: absolute;
  top: 0;
  left: 0;
  width: 24px;
  height: 24px;
  background-color: #ffffff;
  border-radius: 50%;
  display: block;
  align-items: center;
  justify-content: center;
  transform: translate(-12px, -12px);
  z-index: 1000;
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
}

.checkmark svg {
  width: 32px;
  height: 32px;
  display: block;
  transform: translate(-4px, -4px);
}

.footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top: 3px solid #D0D0D0;
  padding-top: 15px;
}

.info-icon {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  background: none;
  border: none;
  padding: 0;
}

.info-icon-img {
  width: 100%;
  height: 100%;
  display: block;
}

.verify-button {
  background-color: #1976d2;
  color: white;
  border: none;
  padding: 12px 36px;
  border-radius: 4px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
}

.verify-button:hover {
  background-color: #1565c0;
}
</style>
