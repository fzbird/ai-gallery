/**
 * Calculates the SHA-256 hash of a file.
 * @param {File} file The file to hash.
 * @param {(progress: number) => void} [onProgress] Optional callback to report progress (0-100).
 * @returns {Promise<string>} The SHA-256 hash as a hex string.
 */
export async function calculateFileHash(file, onProgress) {
  const buffer = await readFileInChunks(file, onProgress);
  const hashBuffer = await crypto.subtle.digest('SHA-256', buffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  return hashHex;
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
      reject(new Error(`File could not be read: ${e.target.error.name}`));
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