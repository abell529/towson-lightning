/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 7/18/17.
 */
({
	getProducts: function (component) {
		var featured = component.get('v.showFeatured');

		var params = featured ? {
			pageSize     : component.get('v.pageSize'),
			currentPage  : component.get('v.currentPage')
		} : {
			pageSize     : component.get('v.pageSize'),
			currentPage  : component.get('v.currentPage'),
			searchFilter : component.get('v.searchString'),
			familyFilter : component.get('v.filterString'),
			sortOrder    : component.get('v.sortString'),
			minimumPrice : component.get('v.minimumPrice'),
			maximumPrice : component.get('v.maximumPrice')
		};

		this.doCallout (component, featured ? 'c.getProductsFeatured' : 'c.getProducts',
					    params,
					    false,
					    'Get Products', false)
			.then(function (products) {
				component.set('v.products',         products);
				component.set('v.pageCount',        products.pageCount);

				// apply the Custom metadata settings, combined with builder settings
				component.set('v.optionsQuantity',  products.quantityList);
				component.set('v.showImage',        !products.hideImages    && component.get('v.showImage'));
				component.set('v.showPrice',        !products.hideUnitPrice && component.get('v.showPrice'));
				component.set('v.showAddToCart',    !products.hideAddToCart && component.get('v.showAddToCart'));

				component.set('v.isInit', true);
			});
	},

	goToPage: function (component, event, buttonClicked) {
		var currentPage = component.get('v.currentPage');

		currentPage = buttonClicked === 'next' ? ++currentPage : --currentPage;
		component.set('v.currentPage', currentPage);

		this.getProducts(component);
	}
})
