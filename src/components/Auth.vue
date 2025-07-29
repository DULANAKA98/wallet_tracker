<template>
  <div class="min-h-screen flex items-center justify-center p-4">
    <div class="max-w-md w-full">
      <!-- Auth Card -->
      <div class="card rounded-lg p-8">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold text-black mb-2">💰 Wallet Tracker</h1>
          <p class="text-white/80">Powered by <strong>Peasy AI</strong></p>
          <p></p>
          <p class="text-white/80">
            Welcome back! Please sign in to your account.
          </p>
        </div>

        <!-- Toggle between Login and Register -->
        <div class="flex mb-6 bg-gray-100 rounded-lg p-1">
          <button
            @click="isLogin = true"
            class="flex-1 py-2 px-4 rounded-md transition-all"
            :class="isLogin ? 'bg-white shadow-sm' : 'text-gray-600'"
          >
            Login
          </button>
          <button
            @click="isLogin = false"
            class="flex-1 py-2 px-4 rounded-md transition-all"
            :class="!isLogin ? 'bg-white shadow-sm' : 'text-gray-600'"
          >
            Register
          </button>
        </div>

        <!-- Login Form -->
        <form v-if="isLogin" @submit.prevent="handleLogin" class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-2">Email</label>
            <input
              v-model="loginForm.email"
              type="email"
              required
              class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter your email"
            />
          </div>
          <div>
            <label class="block text-sm font-medium mb-2">Password</label>
            <input
              v-model="loginForm.password"
              type="password"
              required
              class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter your password"
            />
          </div>
          <button
            type="submit"
            :disabled="loading"
            class="w-full btn-primary py-2 rounded-lg text-white font-medium disabled:opacity-50"
          >
            {{ loading ? "Signing in..." : "Sign In" }}
          </button>
        </form>

        <!-- Register Form -->
        <form v-else @submit.prevent="handleRegister" class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-2">Name</label>
            <input
              v-model="registerForm.name"
              type="text"
              required
              class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter your full name"
            />
          </div>
          <div>
            <label class="block text-sm font-medium mb-2">Email</label>
            <input
              v-model="registerForm.email"
              type="email"
              required
              class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter your email"
            />
          </div>
          <div>
            <label class="block text-sm font-medium mb-2">Password</label>
            <input
              v-model="registerForm.password"
              type="password"
              required
              minlength="6"
              class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter your password (min 6 characters)"
            />
          </div>
          <div>
            <label class="block text-sm font-medium mb-2"
              >Confirm Password</label
            >
            <input
              v-model="registerForm.password_confirmation"
              type="password"
              required
              class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Confirm your password"
            />
            <p v-if="passwordError" class="text-red-500 text-sm mt-1">
              {{ passwordError }}
            </p>
          </div>
          <div>
            <label class="block text-sm font-medium mb-2"
              >Initial Credit (MYR)</label
            >
            <input
              v-model="registerForm.credit"
              type="number"
              min="0"
              step="0.01"
              class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter initial credit amount"
            />
          </div>
          <button
            type="submit"
            :disabled="loading || !passwordsMatch"
            class="w-full btn-primary py-2 rounded-lg text-white font-medium disabled:opacity-50"
          >
            {{ loading ? "Creating account..." : "Create Account" }}
          </button>
        </form>

        <!-- Error Messages -->
        <div
          v-if="error"
          class="mt-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded-lg"
        >
          {{ error }}
        </div>

        <!-- Success Messages -->
        <div
          v-if="success"
          class="mt-4 p-3 bg-green-100 border border-green-400 text-green-700 rounded-lg"
        >
          {{ success }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed } from "vue";
import axios from "axios";

export default {
  name: "Auth",
  emits: ["authenticated"],
  setup(props, { emit }) {
    const isLogin = ref(true);
    const loading = ref(false);
    const error = ref("");
    const success = ref("");

    const loginForm = ref({
      email: "",
      password: "",
    });

    const registerForm = ref({
      name: "",
      email: "",
      password: "",
      password_confirmation: "",
      credit: 0,
    });

    const passwordsMatch = computed(() => {
      return (
        registerForm.value.password === registerForm.value.password_confirmation
      );
    });

    const passwordError = computed(() => {
      if (registerForm.value.password_confirmation && !passwordsMatch.value) {
        return "Passwords do not match";
      }
      return "";
    });

    const handleLogin = async () => {
      loading.value = true;
      error.value = "";
      success.value = "";

      try {
        const response = await axios.post("/api/login", loginForm.value);

        // Store token in localStorage
        localStorage.setItem("authToken", response.data.token);
        localStorage.setItem("user", JSON.stringify(response.data.user));

        // Set default authorization header for future requests
        axios.defaults.headers.common[
          "Authorization"
        ] = `Bearer ${response.data.token}`;

        success.value = response.data.message;

        // Emit authenticated event
        setTimeout(() => {
          emit("authenticated", response.data.user);
        }, 1000);
      } catch (err) {
        error.value =
          err.response?.data?.error || "Login failed. Please try again.";
      } finally {
        loading.value = false;
      }
    };

    const handleRegister = async () => {
      if (!passwordsMatch.value) {
        error.value = "Passwords do not match";
        return;
      }

      loading.value = true;
      error.value = "";
      success.value = "";

      try {
        const response = await axios.post("/api/register", {
          user: registerForm.value,
        });

        // Store token in localStorage
        localStorage.setItem("authToken", response.data.token);
        localStorage.setItem("user", JSON.stringify(response.data.user));

        // Set default authorization header for future requests
        axios.defaults.headers.common[
          "Authorization"
        ] = `Bearer ${response.data.token}`;

        success.value = response.data.message;

        // Emit authenticated event
        setTimeout(() => {
          emit("authenticated", response.data.user);
        }, 1000);
      } catch (err) {
        if (err.response?.data?.errors) {
          error.value = err.response.data.errors.join(", ");
        } else {
          error.value =
            err.response?.data?.error ||
            "Registration failed. Please try again.";
        }
      } finally {
        loading.value = false;
      }
    };

    return {
      isLogin,
      loading,
      error,
      success,
      loginForm,
      registerForm,
      passwordsMatch,
      passwordError,
      handleLogin,
      handleRegister,
    };
  },
};
</script>
