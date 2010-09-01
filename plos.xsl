<?xml version='1.0' encoding='utf-8'?>
<!-- 
Copyright (c) 2010 Roderic D. M. Page

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML">

    <xsl:output method="html" version="1.0" encoding="utf-8" indent="yes"/>

    <!-- from http://aspn.activestate.com/ASPN/Cookbook/XSLT/Recipe/65426 -->
    <!-- reusable replace-string function -->
    <xsl:template name="replace-string">
        <xsl:param name="text"/>
        <xsl:param name="from"/>
        <xsl:param name="to"/>

        <xsl:choose>
            <xsl:when test="contains($text, $from)">

                <xsl:variable name="before" select="substring-before($text, $from)"/>
                <xsl:variable name="after" select="substring-after($text, $from)"/>
                <xsl:variable name="prefix" select="concat($before, $to)"/>

                <xsl:value-of select="$before"/>
                <xsl:value-of select="$to"/>
                <xsl:call-template name="replace-string">
                    <xsl:with-param name="text" select="$after"/>
                    <xsl:with-param name="from" select="$from"/>
                    <xsl:with-param name="to" select="$to"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="/">
        <html>
            <head>
                <meta http-equiv="content-type" content="text/html; charset=utf-8"/>

				<script type="text/javascript" src="jquery.js"/>

                <title>PLoS Viewer</title>

                <style type="text/css"> body { padding:20px; margin:0px; font-family: Verdana,
                    Arial, Helvetica, sans-serif; color: #303030; } h1, h2, h3 { font-family:
                    Georgia, "Times New Roman", Times, serif; color: #333; } h1 { font-size: 2.2em;
                    font-weight: normal; line-height:1.1em; color: #333;} h2 { font-size: 1.6em;
                    font-weight: normal; } h3 { font-size: 1.4em; font-weight: normal; } h4 {
                    font-size: 1.2em; } h5 { font-size: 1em; } h6 { font-size: .9em; } .abstract {
                    background-color:rgb(241,247,255); padding-left:10px; padding-right:10px;
                    padding-bottom:10px; -webkit-border-radius:10px; border:2px solid black; }
                    .lookup { /*background-color:rgb(241,247,255);*/ color:rgb(0,102,153);
                    text-decoration: underline; } </style>

            </head>
            <body>
                <div>
                    <!-- article metadata -->
                    <xsl:apply-templates select="//article-meta"/>

                    <!-- article -->
					<div class="abstract">
                    	<xsl:apply-templates select="//abstract"/>
					</div>
                    <xsl:apply-templates select="//body"/>
                    <xsl:apply-templates select="//back"/>

                    <!-- footer stuff, such as figure gallery -->
                    <h2>Figures</h2>
                    <div>
                        <xsl:for-each select="//fig">
                            <div
                                style="display:inline;padding:10px;background-color:white;text-align:center;">

								<xsl:attribute name="id">
									<xsl:value-of select="generate-id(.)"/>
								</xsl:attribute>

                                <a>

                                    <xsl:attribute name="href">
										<xsl:text>images/</xsl:text>
                                        <xsl:value-of select="@id"/>
                                        <xsl:text>_PNG_M.png</xsl:text>
										<xsl:text>#</xsl:text>
										<xsl:value-of select="generate-id(.)"/>
                                    </xsl:attribute>

                                    <xsl:attribute name="title">
                                        <xsl:value-of select="label"/>
                                    </xsl:attribute>


                                    <img>
                                        <xsl:attribute name="src">
											<xsl:text>images/</xsl:text>
                                            <xsl:value-of select="@id"/>
                                            <xsl:text>_PNG_S.png</xsl:text>
                                        </xsl:attribute>
                                    </img>
                                </a>
                                <xsl:value-of select="label"/>


                            </div>
                        </xsl:for-each>
                    </div>


                </div>

                <div id="popup"
                    style="-webkit-border-radius:10px;color:white;position:absolute;top:10px;display:none;z-index:5;width:70%;background:url(images/background.png);padding:10px;">
                    <table width="100%">
                        <tbody style="color:white;font-size:18px;">
                            <tr>
                                <td width="5%">
                                    <span style="font-size:24px;" onclick="$('popup').hide();"
                                    >×</span>
                                </td>
                                <td id="citation"/>
                                <td width="5%" align="right" id="progress"/>
                            </tr>
                        </tbody>
                    </table>
                </div>




            </body>
        </html>
    </xsl:template>

    <!-- display title, authors, copyright, etc. -->
    <xsl:template match="//article-meta">
        <h1>
            <xsl:value-of select="//article-title"/>
        </h1>
        <xsl:apply-templates select="//contrib-group"/>
        <div>
            <xsl:apply-templates select="//corresp"/>
        </div>
		<p>
        	<xsl:text>©</xsl:text>
			<xsl:value-of select="//copyright-year"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="//copyright-statement"/>
		</p>
    </xsl:template>

    <!-- authors -->
    <xsl:template match="//contrib-group">
        <h2>
            <xsl:apply-templates select="contrib"/>
        </h2>
    </xsl:template>

    <!-- contributors -->
    <xsl:template match="contrib">
        <xsl:if test="@contrib-type='author'">
            <xsl:if test="position() != 1">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="name/given-names"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="name/surname"/>
        </xsl:if>

    </xsl:template>

    <!-- corresponding author -->
    <xsl:template match="corresp">
        <a>
            <xsl:attribute name="href">
                <xsl:text>mailto:</xsl:text>
                <xsl:value-of select="email"/>
            </xsl:attribute>
            <xsl:value-of select="email"/>
        </a>
    </xsl:template>

    <!-- abstract -->
    <xsl:template match="//abstract">
        <p>
			<xsl:choose>
		    	<xsl:when test="@abstract-type='summary'"><!-- <h2>Author Summary</h2> --></xsl:when>
				<xsl:otherwise><h2>Abstract</h2></xsl:otherwise>
			</xsl:choose>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="//body">
        <xsl:apply-templates select="sec"/>
    </xsl:template>

    <!-- acknowledgements, references, etc. -->
    <xsl:template match="//back">
        <xsl:apply-templates select="ack"/>

        <!-- embed references
        <xsl:apply-templates select="ref-list"/>
		-->
    </xsl:template>

    <xsl:template match="sec">
        <a>
            <xsl:attribute name="name">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
        </a>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="fig"> </xsl:template>

    <xsl:template match="ack">
        <h2>
            <xsl:text>Acknowledegements</xsl:text>
        </h2>
        <xsl:apply-templates select="p"/>
    </xsl:template>

    <xsl:template match="ref-list">
        <h2>
            <xsl:value-of select="title"/>
        </h2>
        <ol>
            <xsl:apply-templates select="ref"/>
        </ol>
    </xsl:template>


    <!-- basic elements -->
    <xsl:template match="p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="italic">
        <i>
            <xsl:apply-templates/>
        </i>
    </xsl:template>
    <xsl:template match="bold">
        <b>
            <xsl:apply-templates/>
        </b>
    </xsl:template>

    <!-- weight title by depth -->
    <xsl:template match="title">
        <xsl:choose>
            <xsl:when test="../sec/@id != ''">
                <h2>
                    <xsl:apply-templates/>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3>
                    <xsl:apply-templates/>
                </h3>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="list">
        <ul>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="list-item">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <!-- PLoS external link -->
    <xsl:template match="ext-link">
        <xsl:choose>
            <xsl:when test="@ext-link-type='uri'">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="@xlink:href"/>
                    </xsl:attribute>
                    <xsl:value-of select="@xlink:href"/>
                </a>
            </xsl:when>
        </xsl:choose>
    </xsl:template>



    <!-- supplementary-material -->
    <xsl:template match="supplementary-material">
        <div>
            <a>
                <xsl:attribute name="name">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </a>


            <h4>
                <xsl:value-of select="label"/>
            </h4>
            <xsl:value-of select="caption"/>
            <xsl:choose>
                <xsl:when test="@mimetype ='application/msword'">
                    <xsl:text>MS Word</xsl:text>
                </xsl:when>
                <xsl:when test="@mimetype ='application/x-excel'">
                    <xsl:text>MS Excel</xsl:text>
                </xsl:when>
                <xsl:when test="@mimetype ='application/pdf'">
                    <xsl:text>PDF</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@mimetype"/>
                </xsl:otherwise>
            </xsl:choose>

        </div>
    </xsl:template>

    <!-- a citation -->
    <xsl:template match="citation">
        <xsl:choose>
            <!-- journal article -->
            <xsl:when test="@citation-type='journal'">

                <!-- openurl -->
                <xsl:text>ctx_ver=Z39.88-2004&amp;rft_val_fmt=info:ofi/fmt:kev:mtx:journal</xsl:text>

                <!-- referring entity (i.e., this article -->
                <xsl:text>&amp;rfe_id=info:doi/</xsl:text>
                <xsl:value-of select="//article-meta/article-id[@pub-id-type='doi']"/>

                <!-- authors -->
                <xsl:for-each select="person-group">
                    <xsl:if test="@person-group-type='author'">

                        <!-- first author -->
                        <xsl:text>&amp;rft.aulast=</xsl:text>
                        <xsl:value-of select="name[1]/surname"/>
                        <xsl:text>&amp;rft.aufirst=</xsl:text>
                        <xsl:value-of select="name[1]/given-names"/>

                        <!-- all authors -->
                        <xsl:for-each select="name">
                            <xsl:text>&amp;rft.au=</xsl:text>
                            <xsl:value-of select="given-names"/>
                            <xsl:text>+</xsl:text>
                            <xsl:value-of select="surname"/>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:for-each>

                <!-- article title -->
                <xsl:text>&amp;rft.atitle=</xsl:text>
                <xsl:call-template name="replace-string">
                    <xsl:with-param name="text" select="article-title"/>
                    <xsl:with-param name="from" select="' '"/>
                    <xsl:with-param name="to" select="'+'"/>
                </xsl:call-template>

                <!-- journal title -->
                <xsl:text>&amp;rft.jtitle=</xsl:text>

                <xsl:call-template name="replace-string">
                    <xsl:with-param name="text" select="source"/>
                    <xsl:with-param name="from" select="' '"/>
                    <xsl:with-param name="to" select="'+'"/>
                </xsl:call-template>

                <!-- details -->
                <xsl:text>&amp;rft.volume=</xsl:text>
                <xsl:value-of select="volume"/>
                <xsl:text>&amp;rft.spage=</xsl:text>
                <xsl:value-of select="fpage"/>
                <xsl:text>&amp;rft.epage=</xsl:text>
                <xsl:value-of select="lpage"/>
                <xsl:text>&amp;rft.date=</xsl:text>
                <xsl:value-of select="year"/>
            </xsl:when>

            <xsl:when test="@citation-type='book'">
                <!-- openurl -->
                <xsl:text>ctx_ver=Z39.88-2004&amp;rft_val_fmt=info:ofi/fmt:kev:mtx:book</xsl:text>

                <!-- referring entity (i.e., this article -->
                <xsl:text>&amp;rfe_id=info:doi/</xsl:text>
                <xsl:value-of select="//article-meta/article-id[@pub-id-type='doi']"/>

                <!-- authors -->
                <xsl:for-each select="person-group">
                    <xsl:if test="@person-group-type='author'">

                        <!-- first author -->
                        <xsl:text>&amp;rft.aulast=</xsl:text>
                        <xsl:value-of select="name[1]/surname"/>
                        <xsl:text>&amp;rft.aufirst=</xsl:text>
                        <xsl:value-of select="name[1]/given-names"/>

                        <!-- all authors -->
                        <xsl:for-each select="name">
                            <xsl:text>&amp;rft.au=</xsl:text>
                            <xsl:value-of select="given-names"/>
                            <xsl:text>+</xsl:text>
                            <xsl:value-of select="surname"/>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:for-each>

                <!-- book title -->
                <xsl:text>&amp;rft.btitle=</xsl:text>
                <xsl:call-template name="replace-string">
                    <xsl:with-param name="text" select="article-title"/>
                    <xsl:with-param name="from" select="' '"/>
                    <xsl:with-param name="to" select="'+'"/>
                </xsl:call-template>

                <!-- publisher -->
                <xsl:if test="publisher-name != ''">
                    <xsl:text>&amp;rft.pub=</xsl:text>
                    <xsl:value-of select="publisher-name"/>
                </xsl:if>
                <xsl:if test="publisher-loc != ''">
                    <xsl:text>&amp;rft.place=</xsl:text>
                    <xsl:value-of select="publisher-loc"/>
                </xsl:if>

                <!-- details -->
                <xsl:if test="page-count/@count != ''">
                    <xsl:text>&amp;rft.tpages=</xsl:text>
                    <xsl:value-of select="page-count/@count"/>
                </xsl:if>
                <xsl:text>&amp;rft.date=</xsl:text>
                <xsl:value-of select="year"/>
            </xsl:when>

            <xsl:when test="@citation-type='other'"> </xsl:when>

            <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- cross references within document -->
    <xsl:template match="xref">
        <xsl:choose>
	
            <!-- references -->
            <xsl:when test="@ref-type='bibr'">
                <xsl:variable name="rid" select="@rid"/>
                <span class="lookup">

                    <xsl:attribute name="onclick">
                        <xsl:text>lookahead(this,'</xsl:text>
                        <xsl:apply-templates select="//ref[@id=$rid]/citation"/>
                        <xsl:text>')</xsl:text>
                    </xsl:attribute>

                    <xsl:value-of
                        select="//ref[@id=$rid]/citation/person-group[@person-group-type='author']/name[1]/surname"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="//ref[@id=$rid]/citation/year"/>
                </span>
            </xsl:when>

            <xsl:when test="@ref-type='fig'">
                <xsl:variable name="rid" select="@rid"/>
                <a>
					<xsl:attribute name="id">
						<xsl:value-of select="generate-id(.)"/>
					</xsl:attribute>
						
                    <xsl:attribute name="href">
                        <xsl:text>images/</xsl:text>
                        <xsl:value-of select="@rid"/>
                        <xsl:text>_PNG_M.png</xsl:text>
						<xsl:text>#</xsl:text>
						<xsl:value-of select="generate-id(.)"/>
                    </xsl:attribute>

                    <xsl:attribute name="title">
                        <xsl:value-of select="//fig[@id=$rid]/label"/>
                    </xsl:attribute>


                    <xsl:value-of select="."/>
                </a>
            </xsl:when>

            <xsl:when test="@ref-type='supplementary-material'">
                <a>
                    <xsl:attribute name="href">
                        <xsl:text>#</xsl:text>
                        <xsl:value-of select="@rid"/>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </a>
            </xsl:when>

            <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
