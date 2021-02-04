<template>
  <div class="menu-nav">
    <div class="menu-nav__section">
      <a
        :class="activePage == 'categories' ? 'active' : null"
        :href="`/admin/client_menus/${menuId}/categories`">
        Categories
      </a>

      <a
        :class="activePage == 'menu_items' ? 'active' : null"
        :href="`/admin/client_menus/${menuId}/menu_items`">
        Menu Items
      </a>
    </div>

    <div class="menu-nav__section">
      <a
        :class="activePage == 'results' ? 'active' : null"
        :href="`/admin/client_menus/${menuId}/results`">
        Results
      </a>
    </div>
  </div>
</template>

<script>
  export default {
    props: [
      'activePage',
      'menuId'
    ]
  }
</script>
