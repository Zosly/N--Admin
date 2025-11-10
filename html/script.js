// N-Admin - Créé par discord : nano.pasa

let currentPlayers = [];
let currentPermissions = [];
let currentRank = null;
let selectedPlayer = null;
let currentVehicleCategory = null;
let config = {};
let currentReports = {}; // ✅ NOUVEAU : Reports

// Message de crédits dans la console
console.log('%c💜 N-Admin', 'color: #667eea; font-size: 20px; font-weight: bold;');
console.log('%cCréé par discord : nano.pasa', 'color: #764ba2; font-size: 14px;');

// Initialisation
window.addEventListener('message', (event) => {
    const data = event.data;

    switch (data.action) {
        case 'openMenu':
            openMenu(data);
            break;
        case 'closeMenu':
            closeMenu();
            break;
        case 'updateReports': // ✅ NOUVEAU - Mise à jour en temps réel
            loadReports(data.reports);
            break;
        case 'newReport': // ✅ NOUVEAU - Notification nouveau report
            if (currentReports) {
                currentReports[data.report.id] = data.report;
                loadReports(currentReports);
            }
            break;
    }
});

// Ouvrir le menu
function openMenu(data) {
    currentPlayers = data.players || [];
    currentPermissions = data.permissions || [];
    currentRank = data.rank || 'unknown';
    config = data.config || {};
    currentReports = data.reports || {}; // ✅ NOUVEAU

    document.getElementById('menu-container').classList.remove('hidden');
    document.getElementById('rank-badge').textContent = currentRank.toUpperCase();

    // Mettre à jour le compteur de joueurs
    document.getElementById('player-count').textContent = `${currentPlayers.length} Joueurs`;

    // Charger les joueurs
    loadPlayers();

    // Charger les véhicules
    loadVehicles();

    // Charger les météos
    loadWeathers();

    // Charger les lieux de téléportation
    loadLocations();
    
    // Charger les reports ✅ NOUVEAU
    loadReports(currentReports);
}

// Fermer le menu
function closeMenu() {
    document.getElementById('menu-container').classList.add('hidden');
    fetch('https://fivem-admin-menu/closeMenu', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

// Event listeners
document.getElementById('close-btn').addEventListener('click', closeMenu);

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeMenu();
    }
});

// Tabs
document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const tab = btn.dataset.tab;

        // Désactiver tous les onglets
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));

        // Activer l'onglet sélectionné
        btn.classList.add('active');
        document.getElementById(`tab-${tab}`).classList.add('active');
    });
});

// === JOUEURS ===

// Charger la liste des joueurs
function loadPlayers() {
    const playersList = document.getElementById('players-list');
    playersList.innerHTML = '';

    currentPlayers.forEach(player => {
        const playerCard = document.createElement('div');
        playerCard.className = 'player-card';
        playerCard.onclick = () => openPlayerModal(player);

        const initials = player.name.substring(0, 2).toUpperCase();

        playerCard.innerHTML = `
            <div class="player-info">
                <div class="player-avatar">${initials}</div>
                <div class="player-details">
                    <h4>${player.name}</h4>
                    <p>ID: ${player.id} | ${player.steam.substring(0, 20)}</p>
                </div>
            </div>
            <div class="player-ping">${player.ping}ms</div>
        `;

        playersList.appendChild(playerCard);
    });
}

// Recherche de joueurs
document.getElementById('player-search').addEventListener('input', (e) => {
    const searchTerm = e.target.value.toLowerCase();
    const filteredPlayers = currentPlayers.filter(player =>
        player.name.toLowerCase().includes(searchTerm) ||
        player.id.toString().includes(searchTerm)
    );

    const playersList = document.getElementById('players-list');
    playersList.innerHTML = '';

    filteredPlayers.forEach(player => {
        const playerCard = document.createElement('div');
        playerCard.className = 'player-card';
        playerCard.onclick = () => openPlayerModal(player);

        const initials = player.name.substring(0, 2).toUpperCase();

        playerCard.innerHTML = `
            <div class="player-info">
                <div class="player-avatar">${initials}</div>
                <div class="player-details">
                    <h4>${player.name}</h4>
                    <p>ID: ${player.id} | ${player.steam.substring(0, 20)}</p>
                </div>
            </div>
            <div class="player-ping">${player.ping}ms</div>
        `;

        playersList.appendChild(playerCard);
    });
});

// Actualiser la liste des joueurs
document.getElementById('refresh-players').addEventListener('click', () => {
    fetch('https://fivem-admin-menu/refreshPlayers', {
        method: 'POST',
        body: JSON.stringify({})
    });
});

// Modal joueur
function openPlayerModal(player) {
    selectedPlayer = player;
    document.getElementById('modal-player-name').textContent = player.name;
    document.getElementById('player-modal').classList.remove('hidden');
}

function closePlayerModal() {
    document.getElementById('player-modal').classList.add('hidden');
    selectedPlayer = null;
}

// Actions joueurs
function kickPlayer() {
    const reason = document.getElementById('kick-reason').value || 'Aucune raison';
    fetch('https://fivem-admin-menu/kickPlayer', {
        method: 'POST',
        body: JSON.stringify({
            targetId: selectedPlayer.id,
            reason: reason
        })
    });
    closePlayerModal();
}

function kickPlayerWithReason() {
    kickPlayer();
}

function banPlayer() {
    const reason = document.getElementById('ban-reason').value || 'Aucune raison';
    const duration = document.getElementById('ban-duration').value || 'Permanent';
    fetch('https://fivem-admin-menu/banPlayer', {
        method: 'POST',
        body: JSON.stringify({
            targetId: selectedPlayer.id,
            reason: reason,
            duration: duration
        })
    });
    closePlayerModal();
}

function banPlayerWithReason() {
    banPlayer();
}

function freezePlayer() {
    fetch('https://fivem-admin-menu/freezePlayer', {
        method: 'POST',
        body: JSON.stringify({
            targetId: selectedPlayer.id,
            freeze: true
        })
    });
}

function teleportToPlayer() {
    fetch('https://fivem-admin-menu/gotoPlayer', {
        method: 'POST',
        body: JSON.stringify({
            targetId: selectedPlayer.id
        })
    });
    closePlayerModal();
}

function bringPlayer() {
    fetch('https://fivem-admin-menu/bringPlayer', {
        method: 'POST',
        body: JSON.stringify({
            targetId: selectedPlayer.id
        })
    });
}

function spectatePlayer() {
    fetch('https://fivem-admin-menu/spectatePlayer', {
        method: 'POST',
        body: JSON.stringify({
            targetId: selectedPlayer.id
        })
    });
    closePlayerModal();
}

function revivePlayer() {
    fetch('https://fivem-admin-menu/revivePlayer', {
        method: 'POST',
        body: JSON.stringify({
            targetId: selectedPlayer.id
        })
    });
}

function healPlayer() {
    fetch('https://fivem-admin-menu/healPlayer', {
        method: 'POST',
        body: JSON.stringify({
            targetId: selectedPlayer.id
        })
    });
}

function giveArmor() {
    fetch('https://fivem-admin-menu/giveArmor', {
        method: 'POST',
        body: JSON.stringify({
            targetId: selectedPlayer.id
        })
    });
}

function killPlayer() {
    fetch('https://fivem-admin-menu/killPlayer', {
        method: 'POST',
        body: JSON.stringify({
            targetId: selectedPlayer.id
        })
    });
}

// === VÉHICULES ===

// Charger les véhicules
function loadVehicles() {
    const categoriesContainer = document.getElementById('vehicle-categories');
    const vehicleGrid = document.getElementById('vehicle-grid');

    categoriesContainer.innerHTML = '';
    vehicleGrid.innerHTML = '';

    if (!config.vehicles || config.vehicles.length === 0) return;

    // Créer les boutons de catégories
    config.vehicles.forEach((category, index) => {
        const btn = document.createElement('button');
        btn.className = 'category-btn';
        if (index === 0) btn.classList.add('active');
        btn.textContent = category.label;
        btn.onclick = () => selectVehicleCategory(index);
        categoriesContainer.appendChild(btn);
    });

    // Charger la première catégorie
    selectVehicleCategory(0);
}

function selectVehicleCategory(index) {
    currentVehicleCategory = index;

    // Mettre à jour les boutons
    document.querySelectorAll('.category-btn').forEach((btn, i) => {
        if (i === index) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });

    // Charger les véhicules de la catégorie
    const vehicleGrid = document.getElementById('vehicle-grid');
    vehicleGrid.innerHTML = '';

    const category = config.vehicles[index];
    category.vehicles.forEach(vehicle => {
        const btn = document.createElement('button');
        btn.className = 'vehicle-btn';
        btn.textContent = vehicle.name;
        btn.onclick = () => spawnVehicle(vehicle.model);
        vehicleGrid.appendChild(btn);
    });
}

function spawnVehicle(model) {
    fetch('https://fivem-admin-menu/spawnVehicle', {
        method: 'POST',
        body: JSON.stringify({
            model: model
        })
    });
}

function deleteVehicle() {
    fetch('https://fivem-admin-menu/deleteVehicle', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function repairVehicle() {
    fetch('https://fivem-admin-menu/repairVehicle', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function cleanVehicle() {
    fetch('https://fivem-admin-menu/cleanVehicle', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function flipVehicle() {
    fetch('https://fivem-admin-menu/flipVehicle', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function maxTuneVehicle() {
    fetch('https://fivem-admin-menu/maxTuneVehicle', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

// === SERVEUR ===

function sendAnnounce() {
    const message = document.getElementById('announce-input').value;
    if (!message) return;

    fetch('https://fivem-admin-menu/announce', {
        method: 'POST',
        body: JSON.stringify({
            message: message
        })
    });

    document.getElementById('announce-input').value = '';
}

// Charger les météos
function loadWeathers() {
    const weatherGrid = document.getElementById('weather-grid');
    weatherGrid.innerHTML = '';

    if (!config.weathers) return;

    const weatherEmojis = {
        'CLEAR': '☀️',
        'EXTRASUNNY': '🌞',
        'CLOUDS': '☁️',
        'OVERCAST': '🌥️',
        'RAIN': '🌧️',
        'CLEARING': '🌤️',
        'THUNDER': '⛈️',
        'SMOG': '🌫️',
        'FOGGY': '🌫️',
        'XMAS': '❄️',
        'SNOWLIGHT': '🌨️',
        'BLIZZARD': '❄️'
    };

    config.weathers.forEach(weather => {
        const btn = document.createElement('button');
        btn.className = 'weather-btn';
        btn.textContent = `${weatherEmojis[weather] || '🌤️'} ${weather}`;
        btn.onclick = () => setWeather(weather);
        weatherGrid.appendChild(btn);
    });
}

function setWeather(weather) {
    fetch('https://fivem-admin-menu/setWeather', {
        method: 'POST',
        body: JSON.stringify({
            weather: weather
        })
    });
}

function setTime() {
    const hour = parseInt(document.getElementById('time-hour').value);
    const minute = parseInt(document.getElementById('time-minute').value);

    fetch('https://fivem-admin-menu/setTime', {
        method: 'POST',
        body: JSON.stringify({
            hour: hour,
            minute: minute
        })
    });
}

function clearArea(radius) {
    fetch('https://fivem-admin-menu/clearArea', {
        method: 'POST',
        body: JSON.stringify({
            radius: radius
        })
    });
}

function clearVehicles() {
    fetch('https://fivem-admin-menu/clearVehicles', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function clearPeds() {
    fetch('https://fivem-admin-menu/clearPeds', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

// === OUTILS ===

function toggleNoclip() {
    fetch('https://fivem-admin-menu/toggleNoclip', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function toggleGodMode() {
    fetch('https://fivem-admin-menu/toggleGodMode', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function toggleInvisible() {
    fetch('https://fivem-admin-menu/toggleInvisible', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function healSelf() {
    fetch('https://fivem-admin-menu/heal', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function suicide() {
    fetch('https://fivem-admin-menu/suicide', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function teleportToWaypoint() {
    fetch('https://fivem-admin-menu/teleportToWaypoint', {
        method: 'POST',
        body: JSON.stringify({})
    });
}

// === TÉLÉPORTATION ===

function loadLocations() {
    const locationGrid = document.getElementById('location-grid');
    locationGrid.innerHTML = '';

    if (!config.locations) return;

    config.locations.forEach(location => {
        const btn = document.createElement('button');
        btn.className = 'location-btn';
        btn.textContent = location.label;
        btn.onclick = () => teleportToLocation(location.coords);
        locationGrid.appendChild(btn);
    });
}

function teleportToLocation(coords) {
    fetch('https://fivem-admin-menu/teleportToCoords', {
        method: 'POST',
        body: JSON.stringify({
            x: coords.x,
            y: coords.y,
            z: coords.z
        })
    });
}

// === REPORTS ===

function loadReports(reports) {
    currentReports = reports || {};
    const reportsList = document.getElementById('reports-list');
    reportsList.innerHTML = '';

    const reportArray = Object.values(currentReports);
    
    // Mettre à jour le badge
    const reportCount = reportArray.length;
    document.getElementById('report-count').textContent = reportCount;

    if (reportArray.length === 0) {
        reportsList.innerHTML = '<div class="no-reports"><p>✅ Aucun report actif</p></div>';
        return;
    }

    reportArray.forEach(report => {
        const reportCard = document.createElement('div');
        reportCard.className = 'report-card';
        if (report.status === 'taken') {
            reportCard.classList.add('taken');
        }

        const initials = report.playerName.substring(0, 2).toUpperCase();
        const statusText = report.status === 'pending' ? '⏳ En attente' : `✅ Pris par ${report.takenByName}`;
        const statusClass = report.status === 'pending' ? '' : 'taken';

        reportCard.innerHTML = `
            <div class="report-header">
                <div class="report-player">
                    <div class="report-player-avatar">${initials}</div>
                    <div class="report-player-info">
                        <h4>${report.playerName}</h4>
                        <p>ID: ${report.playerId} | ${report.timestamp} - ${report.date}</p>
                    </div>
                </div>
                <div class="report-status ${statusClass}">${statusText}</div>
            </div>
            
            <div class="report-message">
                ${report.message}
            </div>
            
            <div class="report-actions">
                ${report.status === 'pending' ? `
                    <button class="btn btn-primary" onclick="takeReport(${report.id})">✋ Prendre en charge</button>
                ` : ''}
                <button class="btn btn-success" onclick="gotoReporter(${report.id})">🚀 Goto</button>
                <button class="btn btn-info" onclick="bringReporter(${report.id})">📥 Bring</button>
                <button class="btn btn-warning" onclick="replyReport(${report.id})">💬 Répondre</button>
                <button class="btn btn-danger" onclick="resolveReport(${report.id})">✅ Résoudre</button>
            </div>
        `;

        reportsList.appendChild(reportCard);
    });
}

function takeReport(reportId) {
    fetch('https://fivem-admin-menu/takeReport', {
        method: 'POST',
        body: JSON.stringify({ reportId: reportId })
    });
}

function gotoReporter(reportId) {
    fetch('https://fivem-admin-menu/gotoReporter', {
        method: 'POST',
        body: JSON.stringify({ reportId: reportId })
    });
}

function bringReporter(reportId) {
    fetch('https://fivem-admin-menu/bringReporter', {
        method: 'POST',
        body: JSON.stringify({ reportId: reportId })
    });
}

function replyReport(reportId) {
    const message = prompt('💬 Réponse au report :');
    if (message && message.trim() !== '') {
        fetch('https://fivem-admin-menu/replyReport', {
            method: 'POST',
            body: JSON.stringify({ 
                reportId: reportId,
                message: message
            })
        });
    }
}

function resolveReport(reportId) {
    fetch('https://fivem-admin-menu/resolveReport', {
        method: 'POST',
        body: JSON.stringify({ reportId: reportId })
    });
}

