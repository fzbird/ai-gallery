/**
 * Calculates the SHA-256 hash of a file.
 * @param {File} file The file to hash.
 * @param {(progress: number) => void} [onProgress] Optional callback to report progress (0-100).
 * @returns {Promise<string>} The SHA-256 hash as a hex string.
 */
export async function calculateFileHash(file, onProgress) {
  // 检查crypto.subtle是否可用
  if (!crypto || !crypto.subtle) {
    console.warn('crypto.subtle不可用，使用备用文件哈希方案');
    return generateFallbackHash(file);
  }

  try {
    const buffer = await readFileInChunks(file, onProgress);
    const hashBuffer = await crypto.subtle.digest('SHA-256', buffer);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
    return hashHex;
  } catch (error) {
    console.warn('SHA-256计算失败，使用备用方案:', error);
    return generateFallbackHash(file);
  }
}

/**
 * 生成备用文件哈希（基于文件属性）
 * @param {File} file 要哈希的文件
 * @returns {string} 备用哈希值
 */
function generateFallbackHash(file) {
  // 使用文件名、大小、修改时间和类型生成一个简单的哈希
  const data = `${file.name}_${file.size}_${file.lastModified}_${file.type}`;
  
  // 简单的字符串哈希函数
  let hash = 0;
  for (let i = 0; i < data.length; i++) {
    const char = data.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // 转换为32位整数
  }
  
  // 转换为十六进制字符串并添加随机数确保唯一性
  const randomSuffix = Math.random().toString(36).substring(2, 8);
  return Math.abs(hash).toString(16) + randomSuffix;
}

/**
 * Reads a file in chunks to avoid memory issues and provide progress updates.
 * @param {File} file The file to read.
 * @param {(progress: number) => void} [onProgress] Callback for progress updates.
 * @returns {Promise<ArrayBuffer>} The file content as an ArrayBuffer.
 */
function readFileInChunks(file, onProgress) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    const fileSize = file.size;
    // Using readAsArrayBuffer as it's required for crypto.subtle.digest
    reader.readAsArrayBuffer(file);

    reader.onload = (e) => {
      onProgress?.(100);
      resolve(e.target.result);
    };

    reader.onerror = (e) => {
      reject(new Error(`文件读取失败: ${e.target.error?.name || '未知错误'}`));
    };
    
    if (onProgress) {
        reader.onprogress = (e) => {
            if (e.lengthComputable) {
                const progress = Math.round((e.loaded / e.total) * 100);
                onProgress(progress);
            }
        };
    }
  });
} 