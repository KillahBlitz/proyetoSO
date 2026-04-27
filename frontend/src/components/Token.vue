<script setup>
import { ref } from 'vue'

const token = ref('')
const isLoading = ref(false)

const connectWifi = async () => {
  if (!token.value) {
    alert('Por favor ingresa el token')
    return
  }

  isLoading.value = true
  
  try {
    // Simular conexión exitosa
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    // Cerrar la ventana/pestaña
    window.close()
    
    // Si no se puede cerrar (restricciones del navegador), mostrar mensaje
    setTimeout(() => {
      alert('Conexión exitosa. Puedes cerrar esta ventana.')
      isLoading.value = false
    }, 100)
  } catch (error) {
    console.error('Error:', error)
    alert('Error al conectar')
    isLoading.value = false
  }
}
</script>

<template>
  <div class="token-screen">
    <div class="token-container">
      <div class="logo-section">
        <div class="success-icon">✓</div>
        <h1 class="title-main">Casi listo</h1>
      </div>
      
      <div class="content-section">
        <div class="info-box">
          <div class="mail-icon">📧</div>
          <h2 class="title-secondary">Se envió un correo de verificación</h2>
          <p class="info-text">Revisa tu bandeja de entrada</p>
        </div>
        
        <div class="divider">
          <span class="divider-text">O</span>
        </div>
        
        <p class="instruction">Ingresa el token que se te ha descargado</p>
        
        <form @submit.prevent="connectWifi" class="token-form">
          <div class="form-group">
            <input 
              v-model="token"
              type="text"
              placeholder="Ingresa el token aquí"
              class="form-input"
              required
            />
          </div>
          
          <button 
            type="submit" 
            class="connect-button"
            :disabled="isLoading"
          >
            <span v-if="!isLoading">🔌 Conectar WIFI</span>
            <span v-else class="loading-text">Conectando...</span>
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped>
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(-30px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes checkmark {
  0% {
    transform: scale(0) rotate(45deg);
    opacity: 0;
  }
  50% {
    transform: scale(1.2) rotate(45deg);
    opacity: 1;
  }
  100% {
    transform: scale(1) rotate(0deg);
    opacity: 1;
  }
}

.token-screen {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #6a1b3c 0%, #8b0a3d 50%, #a01444 100%);
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  padding: 20px;
  position: relative;
  overflow: hidden;
}

.token-screen::before {
  content: '';
  position: absolute;
  width: 500px;
  height: 500px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 50%;
  top: -100px;
  right: -100px;
  animation: pulse 8s infinite;
}

.token-screen::after {
  content: '';
  position: absolute;
  width: 400px;
  height: 400px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 50%;
  bottom: -100px;
  left: -100px;
  animation: pulse 6s infinite;
}

.token-container {
  background: rgba(255, 255, 255, 0.98);
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
  max-width: 500px;
  width: 100%;
  padding: 0;
  overflow: hidden;
  animation: fadeIn 0.6s ease-out;
  position: relative;
  z-index: 1;
}

.logo-section {
  background: linear-gradient(135deg, #2d8b4e 0%, #1e6d3a 100%);
  padding: 40px 20px;
  text-align: center;
  color: white;
  animation: slideIn 0.8s ease-out;
}

.success-icon {
  font-size: 4em;
  margin-bottom: 10px;
  animation: checkmark 0.8s ease-out;
  font-weight: bold;
}

.title-main {
  font-size: 2.5em;
  margin: 0;
  font-weight: 700;
  letter-spacing: 2px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.content-section {
  padding: 40px 40px 35px;
}

.info-box {
  background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
  border-radius: 15px;
  padding: 25px;
  text-align: center;
  margin-bottom: 25px;
  animation: fadeIn 1s ease-out;
  border: 2px solid #4caf50;
}

.mail-icon {
  font-size: 3em;
  margin-bottom: 10px;
}

.title-secondary {
  font-size: 1.4em;
  color: #2d8b4e;
  margin: 0 0 8px 0;
  font-weight: 600;
}

.info-text {
  color: #555;
  margin: 0;
  font-size: 0.95em;
}

.divider {
  position: relative;
  text-align: center;
  margin: 30px 0;
  animation: fadeIn 1.2s ease-out;
}

.divider::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  height: 1px;
  background: #ddd;
}

.divider-text {
  position: relative;
  background: rgba(255, 255, 255, 0.98);
  padding: 0 20px;
  color: #999;
  font-weight: 600;
  font-size: 1.1em;
}

.instruction {
  text-align: center;
  color: #555;
  margin: 0 0 25px 0;
  font-size: 1.05em;
  font-weight: 500;
  animation: fadeIn 1.4s ease-out;
}

.token-form {
  animation: fadeIn 1.6s ease-out;
}

.form-group {
  margin-bottom: 25px;
}

.form-input {
  width: 100%;
  padding: 16px 18px;
  border: 2px solid #e0e0e0;
  border-radius: 10px;
  font-size: 1.05em;
  transition: all 0.3s ease;
  box-sizing: border-box;
  font-family: 'Courier New', monospace;
  text-align: center;
  letter-spacing: 2px;
  font-weight: 600;
}

.form-input:focus {
  outline: none;
  border-color: #2d8b4e;
  box-shadow: 0 0 0 3px rgba(45, 139, 78, 0.1);
  transform: translateY(-2px);
}

.form-input::placeholder {
  color: #aaa;
  letter-spacing: normal;
  font-weight: normal;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.connect-button {
  width: 100%;
  padding: 18px;
  background: linear-gradient(135deg, #2d8b4e 0%, #1e6d3a 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1.2em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(45, 139, 78, 0.4);
  font-family: inherit;
}

.connect-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(45, 139, 78, 0.6);
  background: linear-gradient(135deg, #3da15e 0%, #2d8b4e 100%);
}

.connect-button:active:not(:disabled) {
  transform: translateY(0);
}

.connect-button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.loading-text {
  display: inline-block;
  animation: pulse 1.5s infinite;
}

/* Responsive para tablets */
@media (max-width: 768px) {
  .token-container {
    max-width: 450px;
  }
  
  .content-section {
    padding: 35px 30px 30px;
  }
  
  .title-main {
    font-size: 2em;
  }
  
  .title-secondary {
    font-size: 1.2em;
  }
}

/* Responsive para móviles */
@media (max-width: 480px) {
  .content-section {
    padding: 30px 20px 25px;
  }
  
  .logo-section {
    padding: 30px 20px;
  }
  
  .success-icon {
    font-size: 3em;
  }
  
  .title-main {
    font-size: 1.8em;
  }
  
  .info-box {
    padding: 20px;
  }
  
  .mail-icon {
    font-size: 2.5em;
  }
}
</style>
