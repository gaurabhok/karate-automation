Feature: multipart files (multiple)

Background:
* url demoBaseUrl

Scenario: upload multiple files
    * def json = {}
    * set json.myFile1 = { read: 'test.pdf', filename: 'upload-name1.pdf', contentType: 'application/pdf' }
    # if you have dynamic keys you can do this
    * def key = 'myFile2'
    * json[key] = { read: 'test.pdf', filename: 'upload-name2.pdf', contentType: 'application/pdf' }
    Given path 'files', 'multiple'
    # so you can dynamically construct this json if there are multiple files
    And multipart files json
    And multipart field message = 'hello world'
    When method post
    Then status 200
    And match response == [{ id: '#uuid', filename: 'upload-name1.pdf', message: 'hello world', contentType: 'application/pdf' }, { id: '#uuid', filename: 'upload-name2.pdf', message: 'hello world', contentType: 'application/pdf' }]
    And def id1 = response[0].id
    And def id2 = response[1].id

    Given path 'files', id1
    When method get
    Then status 200
    And match response == read('test.pdf')
    And match header Content-Disposition contains 'attachment'
    And match header Content-Disposition contains 'upload-name1.pdf'
    And match header Content-Type == 'application/pdf'

    Given path 'files', id2
    When method get
    Then status 200
    And match response == read('test.pdf')
    And match header Content-Disposition contains 'attachment'
    And match header Content-Disposition contains 'upload-name2.pdf'
    And match header Content-Type == 'application/pdf'

Scenario: upload array of files (field name is the same)
    # just use the same name, and behind the scenes an array of multi-parts will be sent in the request body    
    * def first = { name: 'myFiles', read: 'test.pdf', filename: 'upload-name1.pdf', contentType: 'application/pdf' }
    * def second = { name: 'myFiles', read: 'test.pdf', filename: 'upload-name2.pdf', contentType: 'application/pdf' }
    
    * path 'files', 'array'
    # note how we support an array of files, which can be programmatically built
    # here we use enclosed javascript (refer docs) for convenience, note the round-brackets
    * multipart files ([ first, second ])
    * multipart field message = 'hello world'
    * method post
    * status 200
    * match response == [{ id: '#uuid', filename: 'upload-name1.pdf', message: 'hello world', contentType: 'application/pdf' }, { id: '#uuid', filename: 'upload-name2.pdf', message: 'hello world', contentType: 'application/pdf' }] 
