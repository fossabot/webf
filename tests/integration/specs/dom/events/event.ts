describe('Event', () => {
  it('should work with order', async () => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
      padding: '20px',
      backgroundColor: '#999',
      margin: '40px',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    const container2 = document.createElement('div');
    setElementStyle(container2, {
      padding: '20px',
      height: '100px',
      backgroundColor: '#f40',
      margin: '40px',
    });
    container2.appendChild(document.createTextNode('DIV 2'));

    container1.appendChild(container2);

    document.body.addEventListener('click', function listener() {
      wrapper.appendChild(document.createTextNode('BODY clicked, '));
      document.body.removeEventListener('click', listener);
    });
    container1.addEventListener('click', () => {
      wrapper.appendChild(document.createTextNode('DIV 1 clicked, '));
    });
    container2.addEventListener('click', () => {
      wrapper.appendChild(document.createTextNode('DIV 2 clicked, '));
    });

    const wrapper = document.createElement('div');
    document.body.appendChild(wrapper);
    wrapper.appendChild(document.createTextNode('Click DIV 2: '));

    container2.click();
    await matchScreenshot();
  });
});
