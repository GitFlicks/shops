let currentShop = null;
let cart = [];
let totalPrice = 0;

// DOM Elements
const shopContainer = document.getElementById('shopContainer');
const shopTitle = document.getElementById('shopTitle');
const itemsGrid = document.getElementById('itemsGrid');
const cartItems = document.getElementById('cartItems');
const totalPriceElement = document.getElementById('totalPrice');
const closeBtn = document.getElementById('closeBtn');
const purchaseBtn = document.getElementById('purchaseBtn');
const paymentMethod = document.getElementById('paymentMethod');
const notification = document.getElementById('notification');

// Event Listeners
closeBtn.addEventListener('click', closeShop);
purchaseBtn.addEventListener('click', purchaseItems);

// Listen for messages from client
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openShop':
            openShop(data.shop);
            break;
        case 'purchaseResult':
            handlePurchaseResult(data.success, data.message);
            break;
    }
});

// Open shop
function openShop(shop) {
    currentShop = shop;
    cart = [];
    totalPrice = 0;
    
    shopTitle.textContent = shop.name;
    renderItems(shop.items);
    updateCart();
    
    shopContainer.style.display = 'block';
    document.body.style.overflow = 'hidden';
}

// Close shop
function closeShop() {
    shopContainer.style.display = 'none';
    document.body.style.overflow = 'auto';
    
    // Send close message to client
    fetch(`https://${GetParentResourceName()}/closeShop`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

// Render items
function renderItems(items) {
    itemsGrid.innerHTML = '';
    
    items.forEach((item, index) => {
        const itemCard = document.createElement('div');
        itemCard.className = 'item-card';
        
        // Create image element with fallback
        const imageUrl = item.image ? `images/${item.image}` : null;
        const imageHtml = imageUrl ? 
            `<img src="${imageUrl}" alt="${item.label}" class="item-image-img" onerror="this.parentNode.innerHTML='📦'; this.parentNode.classList.add('fallback-icon');">` : 
            '';
        
        itemCard.innerHTML = `
            <div class="item-image ${!imageUrl ? 'fallback-icon' : ''}">${imageHtml || '📦'}</div>
            <div class="item-name">${item.label}</div>
            <div class="item-price">${item.price}</div>
            <div class="item-description">${item.description}</div>
            <button class="add-to-cart-btn" onclick="addToCart('${item.name}', '${item.label}', ${item.price})">
                Add to Cart
            </button>
        `;
        
        itemsGrid.appendChild(itemCard);
    });
}

// Add item to cart
function addToCart(itemName, itemLabel, itemPrice) {
    const existingItem = cart.find(item => item.name === itemName);
    
    if (existingItem) {
        existingItem.quantity += 1;
    } else {
        cart.push({
            name: itemName,
            label: itemLabel,
            price: itemPrice,
            quantity: 1
        });
    }
    
    updateCart();
    showNotification('Item added to cart!', 'success');
}

// Remove item from cart
function removeFromCart(itemName) {
    cart = cart.filter(item => item.name !== itemName);
    updateCart();
    showNotification('Item removed from cart!', 'success');
}

// Update item quantity
function updateQuantity(itemName, change) {
    const item = cart.find(item => item.name === itemName);
    if (item) {
        item.quantity += change;
        if (item.quantity <= 0) {
            removeFromCart(itemName);
            return;
        }
        updateCart();
    }
}

// Update cart display
function updateCart() {
    cartItems.innerHTML = '';
    totalPrice = 0;
    
    if (cart.length === 0) {
        cartItems.innerHTML = '<div class="empty-cart">Your cart is empty</div>';
        purchaseBtn.disabled = true;
        totalPriceElement.textContent = '$0';
        return;
    }
    
    cart.forEach(item => {
        const itemTotal = item.price * item.quantity;
        totalPrice += itemTotal;
        
        const cartItem = document.createElement('div');
        cartItem.className = 'cart-item';
        
        cartItem.innerHTML = `
            <div class="cart-item-info">
                <div class="cart-item-name">${item.label}</div>
                <div class="cart-item-price">$${item.price} x ${item.quantity} = $${itemTotal}</div>
            </div>
            <div class="cart-item-controls">
                <button class="quantity-btn" onclick="updateQuantity('${item.name}', -1)">-</button>
                <span class="quantity-display">${item.quantity}</span>
                <button class="quantity-btn" onclick="updateQuantity('${item.name}', 1)">+</button>
                <button class="remove-btn" onclick="removeFromCart('${item.name}')">&times;</button>
            </div>
        `;
        
        cartItems.appendChild(cartItem);
    });
    
    totalPriceElement.textContent = `$${totalPrice}`;
    purchaseBtn.disabled = false;
}

// Purchase items
function purchaseItems() {
    if (cart.length === 0) {
        showNotification('Your cart is empty!', 'error');
        return;
    }
    
    const selectedPaymentMethod = paymentMethod.value;
    
    // Disable purchase button to prevent double clicking
    purchaseBtn.disabled = true;
    purchaseBtn.textContent = 'Processing...';
    
    // Send purchase request to server
    fetch(`https://${GetParentResourceName()}/purchaseItems`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            cart: cart,
            paymentMethod: selectedPaymentMethod,
            totalPrice: totalPrice
        })
    });
}

// Handle purchase result
function handlePurchaseResult(success, message) {
    purchaseBtn.disabled = false;
    purchaseBtn.textContent = 'PURCHASE';
    
    if (success) {
        showNotification(message, 'success');
        cart = [];
        updateCart();
        // Close shop after successful purchase
        setTimeout(() => {
            closeShop();
        }, 2000);
    } else {
        showNotification(message, 'error');
    }
}

// Show notification
function showNotification(message, type) {
    notification.textContent = message;
    notification.className = `notification ${type}`;
    notification.classList.add('show');
    
    setTimeout(() => {
        notification.classList.remove('show');
    }, 3000);
}

// Get resource name for NUI callbacks
function GetParentResourceName() {
    return window.location.hostname;
}

// Handle ESC key to close shop
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeShop();
    }
});

// Prevent context menu
document.addEventListener('contextmenu', function(event) {
    event.preventDefault();
});

// Handle window focus/blur for better performance
window.addEventListener('blur', function() {
    // Pause any animations or reduce performance when not focused
});

window.addEventListener('focus', function() {
    // Resume animations when focused
});