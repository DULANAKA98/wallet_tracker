<template>
  <div class="min-h-screen p-4">
    <!-- Authentication Screen -->
    <Auth v-if="!isAuthenticated" @authenticated="handleAuthentication" />

    <!-- Main Application -->
    <div v-else class="max-w-7xl mx-auto">
      <!-- Session Warning -->
      <SessionWarning
        :last-activity="lastActivity"
        :session-duration="SESSION_DURATION"
        @extend-session="extendSession"
      />

      <!-- Header with Logout -->
      <header class="text-center mb-8">
        <div class="flex justify-between items-center mb-4">
          <div></div>
          <button
            @click="logout"
            class="btn-secondary px-4 py-2 rounded-lg text-white font-medium"
          >
            Logout
          </button>
        </div>
        <h1 class="text-4xl font-bold text-white mb-2">💰 Wallet Tracker</h1>
        <p class="text-white/80">
          <strong>Welcome, {{ currentUser.name }}!</strong>
        </p>
      </header>

      <!-- Main Content -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Wallet Section -->
        <div class="lg:col-span-1">
          <div class="card rounded-lg p-6 mb-6">
            <h2 class="text-2xl font-semibold mb-4">Wallet</h2>
            <div class="wallet-balance rounded-lg p-4 mb-4">
              <p class="text-sm opacity-90">Current Balance</p>
              <p class="text-3xl font-bold">MYR {{ currentUser.credit }}</p>
            </div>

            <!-- Top Up Form -->
            <div class="mb-4">
              <label class="block text-sm font-medium mb-2"
                >Top Up Amount</label
              >
              <div class="flex gap-2">
                <input
                  v-model="topUpAmount"
                  type="number"
                  min="0"
                  step="0.01"
                  class="flex-1 px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Enter amount"
                />
                <button
                  @click="topUpWallet"
                  class="btn-success px-4 py-2 rounded-lg text-white font-medium"
                  :disabled="!topUpAmount || topUpAmount <= 0"
                >
                  Top Up
                </button>
              </div>
            </div>
          </div>

          <!-- Recent Transactions -->
          <div class="card rounded-lg p-6">
            <h2 class="text-2xl font-semibold mb-4">Recent Transactions</h2>
            <div
              v-if="transactions.length === 0"
              class="text-gray-500 text-center py-4"
            >
              No transactions yet
            </div>
            <div v-else class="space-y-3">
              <div
                v-for="transaction in transactions.slice(0, 5)"
                :key="transaction.id"
                class="transaction-item p-3 border rounded-lg"
              >
                <div class="flex justify-between items-center">
                  <div>
                    <p class="font-medium">
                      {{
                        transaction.transaction_type === "purchase"
                          ? "Purchase"
                          : "Top Up"
                      }}
                    </p>
                    <p class="text-sm text-gray-600">
                      {{ transaction.product?.name || "Wallet top up" }}
                    </p>
                    <p class="text-xs text-gray-500">
                      {{ new Date(transaction.created_at).toLocaleString() }}
                    </p>
                  </div>
                  <div class="text-right">
                    <p
                      class="font-bold"
                      :class="
                        transaction.transaction_type === 'purchase'
                          ? 'text-red-600'
                          : 'text-green-600'
                      "
                    >
                      {{
                        transaction.transaction_type === "purchase" ? "-" : "+"
                      }}MYR{{ transaction.amount }}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Products Section -->
        <div class="lg:col-span-2">
          <div class="card rounded-lg p-6">
            <div class="flex justify-between items-center mb-6">
              <div>
                <h2 class="text-2xl font-semibold">Available Products</h2>
                <p
                  v-if="products.length > 0"
                  class="text-sm text-gray-500 mt-1"
                >
                  Last updated: {{ getLatestUpdateTime() }}
                </p>
              </div>
              <button
                @click="fetchProductsFromAPI"
                class="btn-primary px-4 py-2 rounded-lg text-white font-medium"
              >
                Refresh Products
              </button>
            </div>

            <div v-if="loading" class="text-center py-8">
              <div
                class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"
              ></div>
              <p class="mt-4 text-gray-600">Loading products...</p>
            </div>

            <div v-else-if="products.length === 0" class="text-center py-8">
              <p class="text-gray-500">No products available</p>
              <button
                @click="fetchProductsFromAPI"
                class="btn-primary px-4 py-2 rounded-lg text-white font-medium mt-4"
              >
                Fetch Products
              </button>
            </div>

            <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div
                v-for="product in products"
                :key="product.id"
                class="product-card border rounded-lg overflow-hidden"
              >
                <img
                  :src="product.image_url"
                  :alt="product.name"
                  class="w-full h-48 object-cover"
                  @error="handleImageError"
                  @load="handleImageLoad"
                />
                <div class="p-4">
                  <h3 class="font-semibold text-lg mb-2">{{ product.name }}</h3>
                  <p class="text-gray-600 text-sm mb-3 line-clamp-2">
                    {{ product.description }}
                  </p>
                  <div class="flex justify-between items-center">
                    <p class="text-2xl font-bold text-green-600">
                      MYR{{ product.price }}
                    </p>
                    <button
                      @click="purchaseProduct(product)"
                      class="btn-success px-4 py-2 rounded-lg text-white font-medium"
                      :disabled="!canAfford(product.price)"
                    >
                      {{
                        canAfford(product.price)
                          ? "Buy Now"
                          : "Insufficient Funds"
                      }}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed, onUnmounted } from "vue";
import axios from "axios";
import Auth from "./components/Auth.vue";
import SessionWarning from "./components/SessionWarning.vue";

export default {
  name: "App",
  components: {
    Auth,
    SessionWarning,
  },
  setup() {
    const products = ref([]);
    const transactions = ref([]);
    const currentUser = ref(null);
    const topUpAmount = ref("");
    const loading = ref(false);
    const isAuthenticated = ref(false);

    // Session management
    const sessionTimeout = ref(null);
    const lastActivity = ref(Date.now());
    const SESSION_DURATION = 30 * 60 * 1000; // 30 minutes in milliseconds

    const API_BASE = "/api";

    // Activity tracking functions
    const updateActivity = () => {
      lastActivity.value = Date.now();
    };

    const resetSessionTimer = () => {
      if (sessionTimeout.value) {
        clearTimeout(sessionTimeout.value);
      }

      sessionTimeout.value = setTimeout(() => {
        // Check if user has been inactive for the session duration
        const timeSinceLastActivity = Date.now() - lastActivity.value;
        if (timeSinceLastActivity >= SESSION_DURATION) {
          logout();
          alert("Session expired due to inactivity. Please log in again.");
        }
      }, SESSION_DURATION);
    };

    const setupActivityListeners = () => {
      const events = [
        "mousedown",
        "mousemove",
        "keypress",
        "scroll",
        "touchstart",
        "click",
      ];

      events.forEach((event) => {
        document.addEventListener(event, updateActivity, true);
      });
    };

    const removeActivityListeners = () => {
      const events = [
        "mousedown",
        "mousemove",
        "keypress",
        "scroll",
        "touchstart",
        "click",
      ];

      events.forEach((event) => {
        document.removeEventListener(event, updateActivity, true);
      });
    };

    const extendSession = () => {
      updateActivity();
      resetSessionTimer();
    };

    const canAfford = (price) => {
      if (!currentUser.value) return false;
      const userCredit = parseFloat(currentUser.value.credit);
      const productPrice = parseFloat(price);
      return userCredit >= productPrice;
    };

    const fetchProducts = async () => {
      loading.value = true;
      try {
        const response = await axios.get(`${API_BASE}/products`);
        products.value = response.data;
      } catch (error) {
        console.error("Error fetching products:", error);
      } finally {
        loading.value = false;
      }
    };

    const fetchTransactions = async () => {
      if (!currentUser.value) return;
      try {
        const response = await axios.get(`${API_BASE}/transactions`);
        transactions.value = response.data;
      } catch (error) {
        console.error("Error fetching transactions:", error);
      }
    };

    const topUpWallet = async () => {
      if (!currentUser.value || !topUpAmount.value || topUpAmount.value <= 0)
        return;

      try {
        const response = await axios.post(`${API_BASE}/top_up`, {
          amount: parseFloat(topUpAmount.value),
        });

        // Update user credit
        currentUser.value.credit = response.data.new_balance;

        // Refresh transactions
        await fetchTransactions();

        // Clear form
        topUpAmount.value = "";

        alert("Top up successful!");
      } catch (error) {
        console.error("Error topping up wallet:", error);
        alert("Error topping up wallet");
      }
    };

    const purchaseProduct = async (product) => {
      if (!currentUser.value || !canAfford(product.price)) return;

      try {
        const response = await axios.post(`${API_BASE}/purchase`, {
          product_id: product.id,
        });

        // Update user credit
        currentUser.value.credit = response.data.new_balance;

        // Refresh transactions
        await fetchTransactions();

        alert("Purchase successful!");
      } catch (error) {
        console.error("Error purchasing product:", error);
        alert("Error purchasing product");
      }
    };

    const fetchProductsFromAPI = async () => {
      try {
        await axios.post(`${API_BASE}/products/fetch_from_api`);
        await fetchProducts();
        alert("Products refreshed successfully!");
      } catch (error) {
        console.error("Error fetching products from API:", error);
        alert("Error refreshing products");
      }
    };

    const getLatestUpdateTime = () => {
      if (products.value.length === 0) return "";

      // Find the latest updated_at timestamp among all products
      const latestUpdate = products.value.reduce((latest, product) => {
        const productUpdate = new Date(product.updated_at);
        return productUpdate > latest ? productUpdate : latest;
      }, new Date(0));

      return latestUpdate.toLocaleString();
    };

    const handleImageError = (event) => {
      // Replace broken image with actual product images
      const productName = event.target.alt || "Product";

      // Try to get a specific product image first
      const productImage = getProductImage(productName);
      event.target.src = productImage;

      // If that also fails, show a styled fallback
      event.target.onerror = () => {
        event.target.style.display = "none";
        const parent = event.target.parentElement;
        const fallbackDiv = document.createElement("div");
        fallbackDiv.className =
          "w-full h-48 bg-gradient-to-br from-purple-500 to-blue-600 flex items-center justify-center text-white font-bold text-lg";
        fallbackDiv.textContent = productName;
        parent.insertBefore(fallbackDiv, event.target);
      };
    };

    const handleImageLoad = (event) => {
      // Image loaded successfully
      console.log("Image loaded successfully:", event.target.src);
    };

    const getProductImage = (productName) => {
      // Map product names to actual product images
      const imageMap = {
        iphone:
          "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=300&fit=crop",
        macbook:
          "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300&h=300&fit=crop",
        airpods:
          "https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=300&h=300&fit=crop",
        ipad: "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=300&h=300&fit=crop",
        watch:
          "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=300&h=300&fit=crop",
        laptop:
          "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=300&h=300&fit=crop",
        phone:
          "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=300&fit=crop",
        headphones:
          "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300&h=300&fit=crop",
        tablet:
          "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=300&h=300&fit=crop",
      };

      const lowerName = productName.toLowerCase();
      for (const [key, imageUrl] of Object.entries(imageMap)) {
        if (lowerName.includes(key)) {
          return imageUrl;
        }
      }

      // Fallback to a generic tech product image
      return "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300&h=300&fit=crop";
    };

    const handleAuthentication = (user) => {
      currentUser.value = user;
      isAuthenticated.value = true;

      // Initialize session management
      lastActivity.value = Date.now();
      setupActivityListeners();
      resetSessionTimer();

      // Fetch data after authentication
      fetchProducts();
      fetchTransactions();
    };

    const logout = () => {
      // Clear session timer
      if (sessionTimeout.value) {
        clearTimeout(sessionTimeout.value);
      }

      // Remove activity listeners
      removeActivityListeners();

      // Clear localStorage
      localStorage.removeItem("authToken");
      localStorage.removeItem("user");

      // Clear axios default headers
      delete axios.defaults.headers.common["Authorization"];

      // Reset state
      currentUser.value = null;
      isAuthenticated.value = false;
      products.value = [];
      transactions.value = [];
    };

    const checkAuthStatus = () => {
      const token = localStorage.getItem("authToken");
      const user = localStorage.getItem("user");

      if (token && user) {
        // Set axios default headers
        axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;

        // Set user and authentication status
        currentUser.value = JSON.parse(user);
        isAuthenticated.value = true;

        // Initialize session management
        lastActivity.value = Date.now();
        setupActivityListeners();
        resetSessionTimer();

        // Fetch data
        fetchProducts();
        fetchTransactions();
      }
    };

    onMounted(() => {
      checkAuthStatus();
    });

    onUnmounted(() => {
      // Clean up session timer and event listeners
      if (sessionTimeout.value) {
        clearTimeout(sessionTimeout.value);
      }
      removeActivityListeners();
    });

    return {
      products,
      transactions,
      currentUser,
      topUpAmount,
      loading,
      isAuthenticated,
      lastActivity,
      SESSION_DURATION,
      canAfford,
      topUpWallet,
      purchaseProduct,
      fetchProductsFromAPI,
      getLatestUpdateTime,
      handleImageError,
      handleImageLoad,
      handleAuthentication,
      logout,
      extendSession,
    };
  },
};
</script>
