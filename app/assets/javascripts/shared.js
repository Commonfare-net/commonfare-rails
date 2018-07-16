function momentizeDates(locale) {
  $('.moment-long-date').each(function() {
    this.textContent = moment(
      this.dataset.serverDate,
      'YYYY-MM-DD HH:mm Z',
      locale
    ).format('lll');
  });
  $('.moment-variable-date').each(function() {
    givenDate = moment(
      this.dataset.serverDate,
      'YYYY-MM-DD HH:mm Z',
      locale
    )
    // L:     21/03/2018
    // dddd:  Sunday
    // LT:    15:21
    format = 'L'
    if (givenDate.isAfter(moment().subtract(6, 'days'))) {
      format = 'dddd'
    }
    if (givenDate.isAfter(moment().subtract(1, 'days'))) {
      format = 'LT'
    }
    this.textContent = givenDate.format(format);
  });
}
