<?php $current_page = basename($_SERVER['PHP_SELF']); ?>
<nav class="bottom-nav">
    <a href="dashboard.php" class="nav-item <?php echo ($current_page == 'dashboard.php') ? 'active' : ''; ?>">
        <i class="fa-solid fa-house"></i>
        <span>Dashboard</span>
    </a>
    <a href="history.php" class="nav-item <?php echo ($current_page == 'history.php') ? 'active' : ''; ?>">
        <i class="fa-solid fa-clock-rotate-left"></i>
        <span>Historia</span>
    </a>
    <a href="progress.php" class="nav-item <?php echo ($current_page == 'progress.php') ? 'active' : ''; ?>">
        <i class="fa-solid fa-chart-line"></i>
        <span>Progres</span>
    </a>
    <a href="measurements.php" class="nav-item <?php echo ($current_page == 'measurements.php') ? 'active' : ''; ?>">
        <i class="fa-solid fa-ruler-combined"></i>
        <span>Pomiary</span>
    </a>
</nav>