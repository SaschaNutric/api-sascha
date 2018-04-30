'use strict'

const Bookshelf = require('../commons/bookshelf');
const Slide = require('../models/slide');

const Slides = Bookshelf.Collection.extend({
	model: Slide
});

module.exports = Slides;
