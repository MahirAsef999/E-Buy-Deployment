async function postJSON(path, body) {
  return api(path, {
    method: "POST",
    body: JSON.stringify(body),
  });
}

// If there are errors, clear them
function clearErrors() {
  document.getElementById("emailError").textContent = "";
  document.getElementById("passwordError").textContent = "";
  const msg = document.getElementById("loginMsg");
  msg.textContent = "";
  msg.className = "muted";
  msg.style.display = "none";
  document.getElementById("loginEmail").classList.remove("error");
  document.getElementById("loginPassword").classList.remove("error");
}

// Show error message for specific fields
function showFieldError(fieldId, errorId, message) {
  document.getElementById(errorId).textContent = message;
  document.getElementById(fieldId).classList.add("error");
}

// Email format validation
function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// Login form submission
document.getElementById("loginForm").addEventListener("submit", async (e) => {
  e.preventDefault();
  clearErrors();

  const email = document.getElementById("loginEmail").value.trim();
  const password = document.getElementById("loginPassword").value;
  const msg = document.getElementById("loginMsg");
  let hasError = false;

  // Email (validate and error message)
  if (!email) {
    showFieldError("loginEmail", "emailError", "Email is required");
    hasError = true;
  } else if (!isValidEmail(email)) {
    showFieldError("loginEmail", "emailError", "Please enter a valid email address");
    hasError = true;
  }

  // Password (validate and error messaage)
  if (!password) {
    showFieldError("loginPassword", "passwordError", "Password is required");
    hasError = true;
  } else if (password.length < 8) {
    showFieldError("loginPassword", "passwordError", "Password must be at least 8 characters");
    hasError = true;
  }

  if (hasError) return;

  // Prevent multiple submissions
  const submitBtn = document.getElementById("loginBtn");
  const originalText = submitBtn.textContent;
  submitBtn.disabled = true;
  submitBtn.textContent = "Signing in...";

  try {
    // Attempt login
    const data = await postJSON("/auth/login", { email, password });
    
    // User data will be taken from database when needed
    localStorage.setItem("token", data.token);

    msg.className = "success";
    msg.style.display = "block";
    msg.textContent = "Login successful! Redirecting...";
    console.log("Success: User logged in successfully:", email);

    // Direct to dashboard
    setTimeout(() => {
      window.location.href = "dashboard.html";
    }, 800);

  } catch (err) {
    console.error("Login failed:", err);
    
    // Restore button state
    submitBtn.disabled = false;
    submitBtn.textContent = originalText;
    
    msg.className = "error";
    msg.style.display = "block";
    
    const errorMessage = err.message.toLowerCase();
    
    if (errorMessage.includes("invalid credentials") || 
        errorMessage.includes("401") || 
        errorMessage.includes("unauthorized")) {
      msg.textContent = "Error: Incorrect email or password. Please try again.";
      showFieldError("loginEmail", "emailError", " ");
      showFieldError("loginPassword", "passwordError", "Check your credentials");
    } 
    else if (errorMessage.includes("network")) {
      msg.textContent = "Unable to connect to server. Please check your internet connection.";
    }
    else if (errorMessage.includes("server error")) {
      msg.textContent = "Server error. Please try again in a few moments.";
    }
    else {
      msg.textContent = "Error: " + (err.message || "Login failed. Please try again.");
    }
  }
});

// Email (event listener to clear errors on input)
document.getElementById("loginEmail").addEventListener("input", function () {
  if (this.value) {
    document.getElementById("emailError").textContent = "";
    this.classList.remove("error");
    const msg = document.getElementById("loginMsg");
    if (msg.className === "error") {
      msg.style.display = "none";
    }
  }
});

// Password (event listener to clear errors on input)
document.getElementById("loginPassword").addEventListener("input", function () {
  if (this.value) {
    document.getElementById("passwordError").textContent = "";
    this.classList.remove("error");
    const msg = document.getElementById("loginMsg");
    if (msg.className === "error") {
      msg.style.display = "none";
    }
  }
});

// Clear button
document.getElementById("loginClear").addEventListener("click", () => {
  document.getElementById("loginEmail").value = "";
  document.getElementById("loginPassword").value = "";
  clearErrors();
});

// If user logged in, direct to dashboard
window.addEventListener('DOMContentLoaded', async () => {
  const token = localStorage.getItem('token');
  if (token) {
    try {
      // If token is valid, user data will be returned
      await authedApi('/account/me');
      console.log('Already logged in with valid session, redirecting to dashboard');
      window.location.href = "dashboard.html";
    } catch (error) {
      //Token is invalid/expired, clear it and stay on login page
      console.log('Session expired, clearing token');
      localStorage.removeItem('token');
    }
  }

});


