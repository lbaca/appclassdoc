"""PeopleSoft Application Class API documentation site generator.

Inspired by Javadoc.
"""

# pylint: disable=not-callable

import argparse
import glob
import logging
import os
import os.path
import re
import shutil
import sys
import time
from collections import defaultdict, namedtuple
from collections.abc import Iterable
from enum import Enum

from antlr4 import CommonTokenStream, FileStream

from lxml import etree

from peoplecodeparser.PeopleCodeLexer import PeopleCodeLexer
from peoplecodeparser.PeopleCodeParser import PeopleCodeParser
from peoplecodeparser.PeopleCodeParserVisitor import PeopleCodeParserVisitor

from pkg_resources import resource_filename, resource_stream


# GLOBAL VARIABLES
_verbose = False
_logger = logging.getLogger('appclassdoc')
_re_api = re.compile(r'/\*\*+\s*(.+)\s*\*+/', flags=re.DOTALL)


# MODEL
SuperclassIndexItem = namedtuple('SuperclassIndexItem', ['fqcn', 'superclass'])


class Scope(Enum):
    """Enumeration of scopes."""

    PUBLIC = 'public'
    PROTECTED = 'protected'
    PRIVATE = 'private'


class AppClass:
    """Representation of an Application Class for documentation purposes."""

    __slots__ = ('name', 'package', 'type', 'superclasses', 'subclasses',
                 'is_abstract', 'constructor', 'methods', 'properties',
                 'constants', 'description')
    package_index = defaultdict(list)
    subclass_index = {}
    xsl_class_index = None
    xsl_package_index = None
    xsl_package_overview = None
    xsl_class = None

    def __init__(self, name, package, the_type='class', verb=None,
                 superclass=None):
        """Create a new Application Class object."""
        self.name = name
        self.package = package
        self.type = the_type
        self.superclasses = []
        self.subclasses = []
        self.is_abstract = False
        self.constructor = None
        self.methods = []
        self.properties = []
        self.constants = []
        self.description = None

        if verb and superclass:
            self.superclasses.append(Superclass(verb, superclass))
            try:
                descr = ClassDescr(package, name, the_type)
                AppClass.subclass_index[superclass].append(descr)
            except KeyError:
                AppClass.subclass_index[superclass] = [ClassDescr(package,
                                                                  name,
                                                                  the_type)]
        descr = ClassDescr(None, name, the_type)
        AppClass.package_index[self.package_name].append(descr)

    def is_same_as(self, app_class):
        """Return True if this object and app_class are the same.

        Equality is defined as being the the same Application Class in
        the same Application Package.
        """
        same = False
        if app_class:
            if self.name.lower() == app_class.name.lower():
                same = (self.package_name.lower()
                        == app_class.package_name.lower())
        return same

    @property
    def package_name(self):
        """Return the package name as a concatenated string."""
        return ':'.join(self.package)

    @property
    def superclass(self):
        """Return the immediate superclass of this class."""
        if self.superclasses:
            return self.superclasses[0]
        else:
            return None

    @property
    def fqcn(self):
        """Return the fully qualified Application Class name."""
        return f'{self.package_name}:{self.name}'

    def find_method(self, name):
        """Find a method by name."""
        methods = (m for m in self.methods if m.name.lower() == name.lower())
        return next(methods, None)

    def find_property(self, name):
        """Find a property by name."""
        props = (p for p in self.properties if p.name.lower() == name.lower())
        return next(props, None)

    def sort_members(self):
        """Sort all the Application Class members."""
        self.methods.sort(key=lambda member: member.sort_key)
        self.properties.sort(key=lambda member: member.sort_key)
        self.constants.sort(key=lambda member: member.name.lower())
        self.subclasses.sort(key=lambda c: c.sort_key.lower())

    def get_xml(self):
        """Return an XML representation of the Application Class."""
        node = etree.Element('class', type=self.type)
        if self.is_abstract:
            node.set('abstract', 'true')
        level = str(len(self.package))
        etree.SubElement(node, 'package', level=level).text = self.package_name
        etree.SubElement(node, 'name').text = self.name
        if self.superclasses:
            hier = etree.SubElement(node, 'hierarchy')
            for sup in reversed(self.superclasses):
                hier.append(sup.get_xml())
        if self.subclasses:
            subs = etree.SubElement(node, 'subclasses')
            for sub in self.subclasses:
                sc = etree.SubElement(subs, 'subclass', type=sub.type)
                etree.SubElement(sc, 'package').text = ':'.join(sub.package)
                etree.SubElement(sc, 'name').text = sub.name
        if self.description:
            node.append(self.description.get_xml(version=True, authors=True))
        if self.constructor:
            node.append(self.constructor.get_xml(is_constructor=True))
        if self.constants:
            consts = etree.SubElement(node, 'constants')
            for const in self.constants:
                consts.append(const.get_xml())
        getters = []
        setters = []
        if self.properties:
            props = etree.SubElement(node, 'properties')
            for prop in self.properties:
                props.append(prop.get_prop_xml())
                if prop.is_get:
                    getters.append(prop.get_get_set_xml(True))
                if prop.is_set:
                    setters.append(prop.get_get_set_xml(False))
        if getters:
            gets = etree.SubElement(node, 'getters')
            for gt in getters:
                gets.append(gt)
        if setters:
            sets = etree.SubElement(node, 'setters')
            for st in setters:
                sets.append(st)
        if self.methods:
            methods_node = etree.SubElement(node, 'methods')
            for method in self.methods:
                methods_node.append(method.get_xml())
        return node

    def get_html(self):
        """Return an HTML representation of the Application Class."""
        if AppClass.xsl_class is None:
            xslt_file = resource_stream(__name__, 'xslt/class.xsl')
            xslt = etree.parse(xslt_file)
            AppClass.xsl_class = etree.XSLT(xslt)
        return AppClass.xsl_class(etree.ElementTree(self.get_xml()))

    def __str__(self):
        """Return a string representation of the Application Class header."""
        if self.type == 'interface':
            public_methods = [member for member in self.methods
                              if member.scope == 'public']
            protected_methods = [member for member in self.methods
                                 if member.scope == 'protected']
            private_methods = [member for member in self.methods
                               if member.scope == 'private']
        else:
            public_methods = [member for member in self.methods
                              if member.scope == 'public']
            protected_methods = [member for member in self.methods
                                 if member.scope == 'protected']
            private_methods = [member for member in self.methods
                               if member.scope == 'private']
        public_properties = [member for member in self.properties
                             if member.scope == 'public']
        protected_properties = [member for member in self.properties
                                if member.scope == 'protected']
        private_properties = [member for member in self.properties
                              if member.scope == 'private']
        out = f'package {self.package_name}\n\n'
        if self.is_abstract:
            out += 'abstract '
        out += f'{self.type} {self.name}'
        if self.superclasses:
            out += f' {self.superclasses[0].verb} {self.superclasses[0].fqcn}'
        out += '\n'
        if self.constructor and self.constructor.scope == 'public':
            out += f'   {str(self.constructor)}\n'
            if public_methods or public_properties:
                out += '\n'
        if public_methods:
            for method in public_methods:
                out += f'   {str(method)}\n'
            if public_properties:
                out += '\n'
        if public_properties:
            for prop in public_properties:
                out += f'   {str(prop)}\n'
        if ((self.constructor and self.constructor.scope == 'protected')
                or protected_methods
                or protected_properties):
            if ((self.constructor and self.constructor.scope == 'public')
                    or public_methods
                    or public_properties):
                out += '\n'
            out += 'protected\n'
            if self.constructor and self.constructor.scope == 'protected':
                out += f'   {str(self.constructor)}\n'
                if protected_methods or protected_properties:
                    out += '\n'
            if protected_methods or protected_properties:
                for method in protected_methods:
                    out += f'   {str(method)}\n'
                if protected_properties:
                    if protected_methods:
                        out += '\n'
                    for prop in protected_properties:
                        out += f'   {str(prop)}\n'
        if private_methods or private_properties:
            if (self.constructor
                    or public_methods
                    or public_properties
                    or protected_methods
                    or protected_properties):
                out += '\n'
            out += 'private\n'
            if private_methods or private_properties:
                if private_methods:
                    for method in private_methods:
                        out += f'   {str(method)}\n'
                    if private_properties or self.constants:
                        out += '\n'
                if private_properties:
                    for prop in private_properties:
                        out += f'   {str(prop)}\n'
                    if self.constants:
                        out += '\n'
                if self.constants:
                    for const in self.constants:
                        out += f'   {str(const)}\n'
        return out

    @classmethod
    def find_subclasses_by_fqcn(cls, fqcn):
        """Return all known subclasses for a given Application Class."""
        try:
            return AppClass.subclass_index[fqcn]
        except KeyError:
            return None

    @classmethod
    def _get_package_xml(cls, package):
        """Return an XML representation of a given package."""
        classes = AppClass.package_index[package]
        classes.sort(key=lambda c: c.name)
        level = str(package.count(':') + 1)
        node = etree.Element('package', name=package, level=level)
        if classes:
            for c in classes:
                c_node = etree.SubElement(node, 'class')
                c_node.text = c.name
                if c.type == 'interface':
                    c_node.set('interface', 'true')
        return node

    @classmethod
    def get_package_html(cls, package):
        """Return an HTML representation of a given package."""
        if AppClass.xsl_package_overview is None:
            xslt_file = resource_stream(__name__, 'xslt/package-overview.xsl')
            xslt = etree.parse(xslt_file)
            AppClass.xsl_package_overview = etree.XSLT(xslt)
        html_tree = etree.ElementTree(AppClass._get_package_xml(package))
        return AppClass.xsl_package_overview(html_tree)

    @classmethod
    def _get_class_index_xml(cls, classes):
        """Return an XML representation of the index of a class list."""
        node = etree.Element('classes')
        for c in classes:
            c_node = etree.SubElement(node, 'class', package=c.package_name)
            if c.type == 'interface':
                c_node.set('interface', 'true')
            if c.is_abstract:
                c_node.set('abstract', 'true')
            c_node.text = c.name
        return node

    @classmethod
    def get_class_index_html(cls, classes, target=''):
        """Return an HTML representation of the index of a class list.

        target represents the HTML target frame.
        """
        if AppClass.xsl_class_index is None:
            xslt_file = resource_stream(__name__, 'xslt/class-index.xsl')
            xslt = etree.parse(xslt_file)
            AppClass.xsl_class_index = etree.XSLT(xslt)
        html_tree = etree.ElementTree(AppClass._get_class_index_xml(classes))
        return AppClass.xsl_class_index(html_tree,
                                        target=etree.XSLT.strparam(target))

    @classmethod
    def get_package_index_xml(cls, packages):
        """Return an XML representation of the package index."""
        node = etree.Element('packages')
        for pkg in packages:
            etree.SubElement(node, 'package').text = pkg
        return node

    @classmethod
    def get_package_index_html(cls, packages):
        """Return an HTML representation of the package index."""
        if AppClass.xsl_package_index is None:
            xslt_file = resource_stream(__name__, 'xslt/package-index.xsl')
            xslt = etree.parse(xslt_file)
            AppClass.xsl_package_index = etree.XSLT(xslt)
        html_tree = etree.ElementTree(AppClass.get_package_index_xml(packages))
        return AppClass.xsl_package_index(html_tree)


class ClassDescr:
    """A lightweight class descriptor for use in indexes."""

    __slots__ = ('package', 'name', 'type')

    def __init__(self, package, name, the_type):
        """Initialize the object."""
        self.package = package
        self.name = name
        self.type = the_type

    @property
    def package_name(self):
        """Return the package name as a concatenated string."""
        return ':'.join(self.package)

    @property
    def fqcn(self):
        """Return the fully qualified Application Class name."""
        if self.package:
            fqcn = f'{self.package_name}:{self.name}'
        else:
            fqcn = self.name
        return fqcn

    @property
    def sort_key(self):
        """Return a string by which to sort instances of this class."""
        return f'{self.name}!{self.package_name}'


class Superclass:
    """A lightweight superclass descriptor."""

    __slots__ = ('verb', 'fqcn', 'package', 'name')

    def __init__(self, verb, fqcn):
        """Initialize the object."""
        self.verb = verb
        self.fqcn = fqcn
        if fqcn.find(':') >= 0:
            split_fqcn = fqcn.split(sep=':')
            self.package = split_fqcn[:-1]
            self.name = split_fqcn[-1]
        else:
            self.package = None
            self.name = fqcn

    def get_xml(self):
        """Return an XML representation of the superclass."""
        node = etree.Element('superclass', verb=self.verb)
        if self.package:
            etree.SubElement(node, 'package').text = ':'.join(self.package)
        etree.SubElement(node, 'name').text = self.name
        return node


class Argument:
    """A representation of a method argument."""

    __slots__ = ('name', 'type', 'is_out')

    def __init__(self, name, the_type, is_out=False):
        """Initialize the object."""
        self.name = name
        self.type = the_type
        self.is_out = is_out

    def get_xml(self):
        """Return an XML representation of the argument."""
        node = etree.Element('argument')
        if self.is_out:
            node.set('out', 'true')
        etree.SubElement(node, 'name').text = etree.CDATA(self.name)
        node.append(self.type.get_xml())
        return node

    def __str__(self):
        """Return a string representation of the argument."""
        out = f'{self.name} as {str(self.type)}'
        if self.is_out:
            out += ' out'
        return out


class Constant:
    """A representation of a constant definition."""

    __slots__ = ('name', 'value', 'description')

    def __init__(self, name, value):
        """Initialize the object."""
        self.name = name
        self.value = value
        self.description = None

    def get_xml(self):
        """Return an XML representation of the constant."""
        node = etree.Element('constant')
        etree.SubElement(node, 'name').text = etree.CDATA(self.name)
        etree.SubElement(node, 'value').text = etree.CDATA(self.value)
        if self.description:
            node.append(self.description.get_xml(returns=True))
        return node

    def __str__(self):
        """Return a string representation of the constant."""
        return f'Constant {self.name} = {self.value}'


class Description:
    """A container for an API description."""

    __slots__ = ('summary', 'full', 'version', 'authors', 'params',
                 'exceptions', 'returns')

    def __init__(self, summary, full=[]):
        """Initialize the object."""
        self.summary = summary
        aux_full = [] if full is None else full
        self.full = aux_full if aux_full or not summary else [summary]
        self.version = None
        self.authors = []
        self.params = []
        self.exceptions = []
        self.returns = None

    @property
    def is_empty(self):
        """Return whether the description is functionally empty."""
        return not (self.summary
                    or self.full
                    or self.version
                    or self.authors
                    or self.params
                    or self.exceptions
                    or self.returns)

    def get_xml(self, version=False, authors=False, params=False,
                exceptions=False, returns=False):
        """Return an XML representation of the API description."""
        node = etree.Element('description')
        if self.summary:
            etree.SubElement(node, 'summary').text = etree.CDATA(self.summary)
        if self.full:
            full = etree.SubElement(node, 'full')
            for para in self.full:
                etree.SubElement(full, 'paragraph').text = etree.CDATA(para)
        if version and self.version:
            etree.SubElement(node, 'version').text = etree.CDATA(self.version)
        if authors and self.authors:
            auths = etree.SubElement(node, 'authors')
            for auth in self.authors:
                etree.SubElement(auths, 'author').text = etree.CDATA(auth)
        if params and self.params:
            ps = etree.SubElement(node, 'params')
            for p in self.params:
                etree.SubElement(ps, 'param').text = etree.CDATA(p)
        if exceptions and self.exceptions:
            exs = etree.SubElement(node, 'exceptions')
            for ex in self.exceptions:
                etree.SubElement(exs, 'exception').text = etree.CDATA(ex)
        if returns and self.returns:
            etree.SubElement(node, 'return').text = etree.CDATA(self.returns)
        return node

    def __str__(self):
        """Return a string representation of the API description."""
        return self.summary


class Method:
    """A representation of an Application Class method or constructor."""

    __slots__ = ('name', 'args', 'type', 'scope', 'is_abstract', 'description')

    def __init__(self, name, scope, args=None, the_type=None,
                 is_abstract=False):
        """Initialize the object."""
        self.name = name
        self.args = args
        self.type = the_type
        self.is_abstract = is_abstract
        self.scope = scope
        self.description = None

    @property
    def sort_key(self):
        """Return a string by which to sort instances of this class."""
        if self.scope == 'public':
            order = '1'
        elif self.scope == 'protected':
            order = '2'
        else:
            order = '3'
        return f'{order}{self.name.lower()}'

    def get_xml(self, is_constructor=False):
        """Return an XML representation of the method or construtor."""
        member_type = 'constructor' if is_constructor else 'method'
        node = etree.Element(member_type, scope=self.scope)
        etree.SubElement(node, 'name').text = self.name
        if not is_constructor:
            if self.is_abstract:
                node.set('abstract', 'true')
            if self.type:
                node.append(self.type.get_xml())
        if self.args:
            args = etree.SubElement(node, 'arguments')
            for arg in self.args:
                args.append(arg.get_xml())
        if self.description:
            descr_xml = self.description.get_xml(params=True, exceptions=True,
                                                 returns=True)
            node.append(descr_xml)
        return node

    def __str__(self):
        """Return a string representation of the method or construtor."""
        out = f'method {self.name}('
        if self.args:
            for i, arg in enumerate(self.args):
                if i > 0:
                    out += ', '
                out += str(arg)
        out += ')'
        if self.type:
            out += f' Returns {str(self.type)}'
        if self.is_abstract:
            out += ' abstract'
        return out


class Property:
    """A representation of an Application Class property."""

    __slots__ = ('name', 'type', 'scope', 'is_abstract', 'is_readonly',
                 'is_get', 'is_set', 'is_private', 'definition', 'description',
                 'get_descr', 'set_descr')

    def __init__(self, name, the_type, scope, is_abstract=False,
                 is_readonly=False, is_get=False, is_set=False):
        """Initialize the object."""
        self.name = name
        self.type = the_type
        self.scope = scope
        self.is_abstract = is_abstract
        self.is_readonly = is_readonly
        self.is_get = is_get
        self.is_set = is_set
        self.is_private = (scope == 'private')
        self.definition = 'instance' if self.is_private else 'property'
        self.description = None
        self.get_descr = None
        self.set_descr = None

    @property
    def sort_key(self):
        """Return a string by which to sort instances of this class."""
        if self.scope == 'public':
            order = '1'
        elif self.scope == 'protected':
            order = '2'
        else:
            order = '3'
        return f'{order}{self.name.lower()}'

    def get_prop_xml(self):
        """Return an XML representation of the property definition."""
        node = etree.Element('property', scope=self.scope)
        if not self.is_private:
            if self.is_readonly:
                node.set('readonly', 'true')
            if self.is_get:
                node.set('get', 'true')
            if self.is_set:
                node.set('set', 'true')
            if self.is_abstract:
                node.set('abstract', 'true')
        name_node = etree.SubElement(node, 'name')
        name_node.text = etree.CDATA(self.name)
        node.append(self.type.get_xml())
        if self.description:
            node.append(self.description.get_xml(returns=True))
        return node

    def get_get_set_xml(self, get):
        """Return an XML representation of the property's getter or setter."""
        node = etree.Element('property', scope=self.scope)
        etree.SubElement(node, 'name').text = self.name
        node.append(self.type.get_xml())
        if get:
            descr = self.get_descr or self.description
        else:
            descr = self.set_descr or self.description
        if descr:
            node.append(descr.get_xml(returns=True))
        return node

    def __str__(self):
        """Return a string representation of the property definition."""
        out = f'{self.definition} {self.type} {self.name}'
        if self.is_abstract:
            out += ' abstract'
        if self.is_readonly:
            out += ' readonly'
        elif not self.is_abstract:
            if self.is_get:
                out += ' get'
            if self.is_set:
                out += ' set'
        return out


class Type:
    """A model of a PeopleCode built-in or Application Class type."""

    __slots__ = ('name', 'package', 'array_dimension')

    def __init__(self, name, array_dimension=0):
        """Initialize the object."""
        parts = name.split(sep=':')
        self.name = parts[-1]
        self.package = parts[:-1]
        self.array_dimension = array_dimension

    @property
    def package_name(self):
        """Return the package name as a concatenated string."""
        return ':'.join(self.package)

    @property
    def fqcn(self):
        """Return the fully qualified type name."""
        if self.package:
            fqcn = f'{self.package_name}:{self.name}'
        else:
            fqcn = self.name
        return fqcn

    def get_xml(self):
        """Return an XML representation of the type."""
        node = etree.Element('type')
        if self.array_dimension > 0:
            node.set('array_dimension', str(self.array_dimension))
        if self.package:
            etree.SubElement(node, 'package').text = ':'.join(self.package)
        etree.SubElement(node, 'name').text = self.name
        return node

    def __str__(self):
        """Return a string representation of the type."""
        return ('array of ' * self.array_dimension) + self.fqcn


# PARSER VISITOR
class AppClassDocVisitor(PeopleCodeParserVisitor):
    """A PeopleCode parser visitor for Application Classes."""

    def __init__(self, stream, package, include_private=False):
        """Create the visitor."""
        if isinstance(package, list):
            if 1 <= len(package) <= 3:
                self.stream = stream
                self.package = package
                self.include_private = include_private
                self.private_methods = set()
                self.app_class = None
            else:
                raise ValueError('package must contain between 1 and 3 items, '
                                 f'but contains {len(package)}')
        else:
            raise ValueError('package must be a list of strings, but is '
                             f'{str(type(package))}')

    @classmethod
    def _split_paragraphs(cls, lst):
        """Split API comment text into paragraphs."""
        para = []
        for line in lst:
            if line:
                para.append(line)
            elif para:
                yield ' '.join(para).strip()
                para = []
        if para:
            yield ' '.join(para).strip()

    @classmethod
    def _group_tags(cls, lst):
        """Generate a list of API tags.

        Receives a list of API comment lines starting from the first
        one that includes an '@' symbol, until the end of the API
        comment. Yields a two-element list where the first item is the
        tag name and the second is the content. Tags with no content are
        not yielded.
        """
        if lst:
            tag = []
            for line in lst:
                # Ignore empty lines
                if line:
                    # Look for a tag
                    if line[0] == '@':
                        if tag:
                            # Previous tag existed; close out and yield
                            # previous tag
                            tag_str = ' '.join(tag)
                            tag = tag_str.split(maxsplit=1)
                            if len(tag) > 1:
                                yield tag
                        # Initialize new tag
                        tag = [line[1:]]
                    else:
                        # Continuation from previous tag
                        tag.append(line)
            # Yield last tag
            if tag:
                tag_str = ' '.join(tag)
                tag = tag_str.split(maxsplit=1)
                if len(tag) > 1:
                    yield tag

    def _find_api_comment(self, start):
        """Find API comments immediately preceding a given position."""
        descr = None
        api_comments = self.stream.getHiddenTokensToLeft(
            start.tokenIndex, channel=PeopleCodeLexer.API_COMMENTS)
        if api_comments:
            # Ensure only the last of consecutive API comments is kept.
            # Start by removing opening and closing markers.
            match = _re_api.fullmatch(api_comments[-1].text)
            if match:
                comment_buffer = [line.strip('\r')
                                  for line in match.group(1).split(sep='\n')]
                # Get rid of leading and trailing empty lines
                while (len(comment_buffer) > 0
                        and not comment_buffer[-1].strip()):
                    del comment_buffer[-1]
                while (len(comment_buffer) > 0
                        and not comment_buffer[0].strip()):
                    del comment_buffer[0]
                if comment_buffer:
                    firstAt = None
                    # Remove leading stars and spaces, and trailing
                    # spaces
                    for i, line in enumerate(comment_buffer):
                        line = line.strip().lstrip('*').lstrip()
                        comment_buffer[i] = line
                        if line and line[0] == '@' and not firstAt:
                            firstAt = i
                    if not firstAt:
                        firstAt = len(comment_buffer)
                    all_text = comment_buffer[:firstAt]
                    full = list(AppClassDocVisitor._split_paragraphs(all_text))
                    if full:
                        # Partition after '. ' instead of '.' to avoid
                        # improper splitting of, e.g., "Record.Field"
                        summary = f'{full[0].partition(". ")[0]}.'
                    else:
                        summary = None
                    descr = Description(summary, full=full)
                    tags = None
                    if firstAt < len(comment_buffer):
                        tags = comment_buffer[firstAt:]
                    for tag, content in AppClassDocVisitor._group_tags(tags):
                        tag = tag.lower()
                        if tag == 'param':
                            descr.params.append(content)
                        elif tag in ('exception', 'throw', 'throws'):
                            descr.exceptions.append(content)
                        elif tag in ('return', 'returns'):
                            descr.returns = content
                        elif tag == 'version':
                            descr.version = content
                        elif tag == 'author':
                            descr.authors.append(content)
                        else:
                            _logger.info(f'API comment tag "{tag}" not '
                                         'recognized, ignored.')
                    # if not descr.is_empty:
                    #     _logger.debug(f'API comment: {descr}')
        return descr

    # Visit a parse tree produced by PeopleCodeParser#AppClassProgram.
    def visitAppClassProgram(
            self, ctx: PeopleCodeParser.AppClassProgramContext):
        """Limit visitor to class declaration and body."""
        self.visit(ctx.classDeclaration())
        ctx_class_body = ctx.classBody()
        if ctx_class_body:
            self.visit(ctx_class_body)
        # _logger.debug(etree.tostring(self.app_class.get_xml(),
        #               encoding='utf-8', pretty_print=True).decode())

    # Visit a parse tree produced by PeopleCodeParser#InterfaceProgram.
    def visitInterfaceProgram(
            self, ctx: PeopleCodeParser.InterfaceProgramContext):
        """Limit visitor to interface declaration."""
        self.visit(ctx.interfaceDeclaration())
        # _logger.debug(etree.tostring(self.app_class.get_xml(),
        #               encoding='utf-8', pretty_print=True).decode())

    # Visit a parse tree produced by
    # PeopleCodeParser#ClassDeclarationExtension.
    def visitClassDeclarationExtension(
            self, ctx: PeopleCodeParser.ClassDeclarationExtensionContext):
        """Visiting a class declaration with a superclass."""
        name = ctx.genericID().getText()
        superclass = ctx.superclass().getText()
        _logger.debug('>>> #ClassDeclarationExtension: '
                      f'{name} extends {superclass}')
        self.app_class = AppClass(name, self.package, verb='extends',
                                  superclass=superclass)
        self.app_class.description = self._find_api_comment(ctx.start)
        self.visit(ctx.classHeader())

    # Visit a parse tree produced by
    # PeopleCodeParser#ClassDeclarationImplementation.
    def visitClassDeclarationImplementation(
            self, ctx: PeopleCodeParser.ClassDeclarationImplementationContext):
        """Visiting a class declaration with an implemented interface."""
        name = ctx.genericID().getText()
        interface = ctx.appClassPath().getText()
        _logger.debug('>>> #ClassDeclarationImplementation: '
                      f'{name} implements {interface}')
        self.app_class = AppClass(name, self.package, verb='implements',
                                  superclass=interface)
        self.app_class.description = self._find_api_comment(ctx.start)
        self.visit(ctx.classHeader())

    # Visit a parse tree produced by
    # PeopleCodeParser#ClassDeclarationPlain.
    def visitClassDeclarationPlain(
            self, ctx: PeopleCodeParser.ClassDeclarationPlainContext):
        """Visiting a standalone class declaration."""
        name = ctx.genericID().getText()
        _logger.debug(f'>>> #ClassDeclarationPlain: {name}')
        self.app_class = AppClass(name, self.package)
        self.app_class.description = self._find_api_comment(ctx.start)
        self.visit(ctx.classHeader())

    # Visit a parse tree produced by
    # PeopleCodeParser#InterfaceDeclarationExtension.
    def visitInterfaceDeclarationExtension(
            self, ctx: PeopleCodeParser.InterfaceDeclarationExtensionContext):
        """Visiting an interface declaration with a superclass."""
        name = ctx.genericID().getText()
        superclass = ctx.superclass().getText()
        _logger.debug('>>> #InterfaceDeclarationExtension: '
                      f'{name} extends {superclass}')
        self.app_class = AppClass(name, self.package, the_type='interface',
                                  verb='extends', superclass=superclass)
        self.app_class.description = self._find_api_comment(ctx.start)
        self.visit(ctx.classHeader())

    # Visit a parse tree produced by
    # PeopleCodeParser#InterfaceDeclarationPlain.
    def visitInterfaceDeclarationPlain(
            self, ctx: PeopleCodeParser.InterfaceDeclarationPlainContext):
        """Visiting a standalone interface declaration."""
        name = ctx.genericID().getText()
        _logger.debug(f'>>> #InterfaceDeclarationPlain: {name}')
        self.app_class = AppClass(name, self.package, the_type='interface')
        self.app_class.description = self._find_api_comment(ctx.start)
        self.visit(ctx.classHeader())

    # Visit a parse tree produced by PeopleCodeParser#publicHeader.
    def visitPublicHeader(self, ctx: PeopleCodeParser.PublicHeaderContext):
        """Starting the public header section."""
        _logger.debug('>>> #publicHeader')
        self._scope = Scope.PUBLIC
        self.visitChildren(ctx)

    # Visit a parse tree produced by PeopleCodeParser#protectedHeader.
    def visitProtectedHeader(
            self, ctx: PeopleCodeParser.ProtectedHeaderContext):
        """Starting the protected header section."""
        _logger.debug('>>> #protectedHeader')
        self._scope = Scope.PROTECTED
        self.visitChildren(ctx)

    # Visit a parse tree produced by PeopleCodeParser#privateHeader.
    def visitPrivateHeader(self, ctx: PeopleCodeParser.PrivateHeaderContext):
        """Starting the private header section."""
        _logger.debug('>>> #privateHeader')
        if self.include_private:
            self._scope = Scope.PRIVATE
            self.visitChildren(ctx)

    # Visit a parse tree produced by PeopleCodeParser#methodHeader.
    def visitMethodHeader(self, ctx: PeopleCodeParser.MethodHeaderContext):
        """Visiting a method declaration in the header."""
        method_name = ctx.genericID().getText()
        if self._scope == Scope.PRIVATE:
            self.private_methods.add(method_name.lower())
        _logger.debug(f'>>> #methodHeader: [{self._scope.value}] '
                      f'{method_name}')
        ctx_args = ctx.methodArguments()
        args = None if ctx_args is None else self.visit(ctx_args)
        the_type = self._get_type(ctx.typeT())
        method = Method(method_name, self._scope.value, args=args,
                        the_type=the_type,
                        is_abstract=(ctx.ABSTRACT() is not None))
        method.description = self._find_api_comment(ctx.start)
        if _logger.isEnabledFor(logging.DEBUG):
            _logger.debug(f'<<< #methodHeader: {method}')
        if method_name.lower() == self.app_class.name.lower():
            self.app_class.constructor = method
        else:
            self.app_class.methods.append(method)

    # Visit a parse tree produced by PeopleCodeParser#methodArguments.
    def visitMethodArguments(
            self, ctx: PeopleCodeParser.MethodArgumentsContext):
        """Return a list of method arguments."""
        ctx_args = ctx.methodArgument()
        if _logger.isEnabledFor(logging.DEBUG):
            _logger.debug(f'>>> #methodArguments ({len(ctx_args)})')
        args = [self.visit(ctx_arg) for ctx_arg in ctx_args]
        _logger.debug('<<< #methodArguments')
        return args

    # Visit a parse tree produced by PeopleCodeParser#methodArgument.
    def visitMethodArgument(self, ctx: PeopleCodeParser.MethodArgumentContext):
        """Return a method argument."""
        the_type = self._get_type(ctx.typeT())
        arg = Argument(ctx.USER_VARIABLE().getText(), the_type,
                       is_out=(ctx.OUT() is not None))
        if _logger.isEnabledFor(logging.DEBUG):
            _logger.debug(f'>>> #methodArgument: {arg}')
        return arg

    def _get_type(self, ctx):
        """Return a Type object."""
        if ctx:
            the_type = self.visit(ctx)
            if type(the_type) is str:
                the_type = Type(the_type)
        else:
            the_type = None
        return the_type

    # Visit a parse tree produced by PeopleCodeParser#ArrayType.
    def visitArrayType(self, ctx: PeopleCodeParser.ArrayTypeContext):
        """Return a Type object for an array type."""
        ctx_type = ctx.typeT()
        if ctx_type:
            base_type = self.visit(ctx_type)
        else:
            base_type = 'any'
        the_type = Type(base_type, array_dimension=len(ctx.ARRAY()))
        if _logger.isEnabledFor(logging.DEBUG):
            _logger.debug(f'>>> #ArrayType: {the_type}')
        return the_type

    # Visit a parse tree produced by PeopleCodeParser#BaseExceptionType.
    def visitBaseExceptionType(
            self, ctx: PeopleCodeParser.BaseExceptionTypeContext):
        """Return a string representation of an Exception type."""
        base_type = 'Exception'
        _logger.debug(f'>>> #BaseExceptionType: {base_type}')
        return base_type

    # Visit a parse tree produced by PeopleCodeParser#AppClassType.
    def visitAppClassType(self, ctx: PeopleCodeParser.AppClassTypeContext):
        """Return a string representation of an Application Class type."""
        base_type = ctx.getText()
        _logger.debug(f'>>> #AppClassType: {base_type}')
        return base_type

    # Visit a parse tree produced by PeopleCodeParser#SimpleTypeType.
    def visitSimpleTypeType(self, ctx: PeopleCodeParser.SimpleTypeTypeContext):
        """Return a string representation of a simple (built-in) type."""
        base_type = ctx.getText()
        _logger.debug(f'>>> #SimpleTypeType: {base_type}')
        return base_type

    # Visit a parse tree produced by PeopleCodeParser#PropertyGetSet.
    def visitPropertyGetSet(self, ctx: PeopleCodeParser.PropertyGetSetContext):
        """Visiting a property declaration with get/set."""
        the_type = self._get_type(ctx.typeT())
        prop = Property(ctx.genericID().getText(), the_type, self._scope.value,
                        is_get=True, is_set=(ctx.SET() is not None))
        prop.description = self._find_api_comment(ctx.start)
        if _logger.isEnabledFor(logging.DEBUG):
            _logger.debug(f'>>> #PropertyGetSet: {prop}')
        self.app_class.properties.append(prop)

    # Visit a parse tree produced by PeopleCodeParser#PropertyDirect.
    def visitPropertyDirect(self, ctx: PeopleCodeParser.PropertyDirectContext):
        """Visiting a direct property declaration."""
        the_type = self._get_type(ctx.typeT())
        prop = Property(ctx.genericID().getText(), the_type, self._scope.value,
                        is_abstract=(ctx.ABSTRACT() is not None),
                        is_readonly=(ctx.READONLY() is not None))
        prop.description = self._find_api_comment(ctx.start)
        if _logger.isEnabledFor(logging.DEBUG):
            _logger.debug(f'>>> #PropertyDirect: {prop}')
        self.app_class.properties.append(prop)

    # Visit a parse tree produced by PeopleCodeParser#InstanceDecl.
    def visitInstanceDecl(self, ctx: PeopleCodeParser.InstanceDeclContext):
        """Visiting a private instance variable declaration.

        Private instance variables can be declared many to a line, all
        sharing the same type and API comments.
        """
        the_type = self._get_type(ctx.typeT())
        descr = self._find_api_comment(ctx.start)
        for i, t in enumerate(ctx.USER_VARIABLE(), start=1):
            prop = Property(t.getText(), the_type, self._scope.value)
            prop.description = descr
            if _logger.isEnabledFor(logging.DEBUG):
                _logger.debug(f'>>> #InstanceDecl: [{i}] {prop}')
            self.app_class.properties.append(prop)

    # Visit a parse tree produced by
    # PeopleCodeParser#constantDeclaration.
    def visitConstantDeclaration(
            self, ctx: PeopleCodeParser.ConstantDeclarationContext):
        """Visiting a private constant declaration."""
        const = Constant(ctx.USER_VARIABLE().getText(),
                         ctx.literal().getText())
        const.description = self._find_api_comment(ctx.start)
        if _logger.isEnabledFor(logging.DEBUG):
            _logger.debug(f'>>> #enterConstantDeclaration: {const}')
        self.app_class.constants.append(const)

    # Visit a parse tree produced by
    # PeopleCodeParser#MethodImplementation.
    def visitMethodImplementation(
            self, ctx: PeopleCodeParser.MethodImplementationContext):
        """Visiting a method implementation.

        This is only used to override the API comments in case they're
        defined here instead of (or in addition to) the header method
        declaration.
        """
        method_name = ctx.method().genericID().getText()
        _logger.debug(f'>>> #MethodImplementation: {method_name}')
        if self.include_private or method_name.lower() in self.private_methods:
            descr = self._find_api_comment(ctx.start)
            if descr:
                method = self.app_class.find_method(method_name)
                if method:
                    method.description = descr

    # Visit a parse tree produced by
    # PeopleCodeParser#GetterImplementation.
    def visitGetterImplementation(
            self, ctx: PeopleCodeParser.GetterImplementationContext):
        """Visiting a getter implementation.

        This is only used to assign get-specific API comments to the
        property.
        """
        property_name = ctx.getter().genericID().getText()
        _logger.debug(f'>>> #GetterImplementation: {property_name}')
        prop = self.app_class.find_property(property_name)
        if prop:
            prop.get_descr = self._find_api_comment(ctx.start)

    # Visit a parse tree produced by
    # PeopleCodeParser#SetterImplementation.
    def visitSetterImplementation(
            self, ctx: PeopleCodeParser.SetterImplementationContext):
        """Visiting a setter implementation.

        This is only used to assign set-specific API comments to the
        property.
        """
        property_name = ctx.setter().genericID().getText()
        _logger.debug(f'>>> #SetterImplementation: {property_name}')
        prop = self.app_class.find_property(property_name)
        if prop:
            prop.set_descr = self._find_api_comment(ctx.start)


# PRIVATE FUNCTIONS
def _print_verbose(text, end='\n', flush=True):
    """Print to stdout if verbose output is enabled."""
    if _verbose:
        print(text, end=end, flush=flush)


def _flatten(lst):
    """Generate individual items from a multiple-level list."""
    for elem in lst:
        if isinstance(elem, Iterable) and not isinstance(elem, (str, bytes)):
            yield from _flatten(elem)
        else:
            yield elem


def _process_file(file_path, include_private):
    """Process an input file to retrieve its structure."""
    _logger.info(f'Processing input file "{file_path}"')
    input_stream = FileStream(file_path, encoding='utf-8')
    lexer = PeopleCodeLexer(input_stream)
    token_stream = CommonTokenStream(lexer)
    parser = PeopleCodeParser(token_stream)
    parse_tree = parser.appClass()
    package = os.path.basename(file_path).split(sep='.')[:-2]
    visitor = AppClassDocVisitor(token_stream, package,
                                 include_private=include_private)
    visitor.visit(parse_tree)
    return visitor.app_class


def _process_input(args):
    """Process an input argument.

    Globs files and directories where applicable.
    """
    for arg in _flatten([glob.glob(file) for file in args]):
        if os.path.exists(arg):
            if os.path.isfile(arg):
                yield arg
            elif os.path.isdir(arg):
                directory = os.walk(arg)
                for adir in directory:
                    base_dir = adir[0]
                    for filename in adir[2]:
                        yield os.path.join(base_dir, filename)
            else:
                _logger.warning(f'"{arg}" is neither a file nor a directory, '
                                'skipping.')
        else:
            _logger.warning(f'"{arg}" not found, skipping.')


def _write_package_index(packages, file_path):
    """Write the package index file."""
    with open(file_path, 'wb') as file:
        html = AppClass.get_package_index_html(packages)
        html.write(file, method='html', pretty_print=True, encoding='utf-8')


def _write_class_index(classes, file_path, target=''):
    """Write the class index file."""
    with open(file_path, 'wb') as file:
        html = AppClass.get_class_index_html(classes, target=target)
        html.write(file, method='html', pretty_print=True, encoding='utf-8')


def _write_package_overview(package, file_path):
    """Write a package overview file."""
    with open(file_path, 'wb') as file:
        html = AppClass.get_package_html(package)
        html.write(file, method='html', pretty_print=True, encoding='utf-8')


def _write_class_file_xml(outputdir, app_class):
    """Write a class file as XML."""
    file_path = os.path.join(outputdir, 'api', *app_class.package,
                             f'{app_class.name}.xml')
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, 'wb') as file:
        doc = etree.ElementTree(app_class.get_xml())
        doc.write(file, pretty_print=True, xml_declaration=True,
                  encoding='utf-8')


def _write_class_file_html(outputdir, app_class):
    """Write a class file as HTML."""
    file_path = os.path.join(outputdir, 'api', *app_class.package,
                             f'{app_class.name}.html')
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, 'wb') as file:
        html = app_class.get_html()
        html.write(file, method='html', pretty_print=True, encoding='utf-8')


def _app_classes_with_superclass(lst):
    """Yield all classes that extend/implement from another."""
    for app_class in lst:
        if app_class.superclass:
            yield app_class


def _get_superclasses_for_class(superclass_index, superclass):
    """Return a list with the hierarchy of a superclass."""
    lst = []
    key = superclass
    while key and key.package:
        superclasses = (sc.superclass for sc in superclass_index
                        if sc.fqcn.lower() == key.fqcn.lower())
        key = next(superclasses, None)
        if key:
            lst.append(key)
    return lst


def _remove_dir(path):
    """Delete a directory recursively."""
    if os.path.exists(path):
        if os.path.isdir(path):
            shutil.rmtree(path)
        else:
            raise NotADirectoryError(f'"{path}" is not a directory')


# PUBLIC FUNCTIONS
def generate_appclassdoc(outputdir, include_private, do_deletes, files,
                         verbose_output=False):
    """Perform the main functionality of this module."""
    global _verbose
    _verbose = verbose_output
    if files:
        if type(files) is str:
            file_list = [files]
        else:
            file_list = files
    else:
        raise ValueError('No files or directories provided')
    outputdir = outputdir.rstrip(os.sep)
    _logger.info(f'Output directory: "{outputdir}"')
    if os.path.exists(outputdir) and not os.path.isdir(outputdir):
        raise ValueError(f'"{outputdir}" is not a directory')
    else:
        os.makedirs(outputdir, exist_ok=True)
    start_time = time.time()
    app_classes = []
    parse_errors = 0
    _print_verbose('Parsing source files...')
    for file_path in _process_input(file_list):
        app_class = _process_file(file_path, include_private)
        if app_class:
            app_classes.append(app_class)
        else:
            parse_errors += 1
            _logger.warning(f'File "{file_path}" does not appear to contain a '
                            'class definition')
    if parse_errors > 0:
        error_text = f', {parse_errors} parse error(s),'
    else:
        error_text = ''
    _print_verbose(f'{len(app_classes)} class(es) parsed successfully'
                   f'{error_text} in {(time.time() - start_time):.1f} s.')
    if app_classes:
        start_time = time.time()
        _print_verbose('Resolving class hierarchies...', end='', flush=True)
        app_classes.sort(key=lambda c: f'{c.name}:{c.package_name}')
        superclass_index = []
        for app_class in app_classes:
            superclass = app_class.superclass
            if superclass:
                item = SuperclassIndexItem(app_class.fqcn, superclass)
                superclass_index.append(item)
            subclasses = AppClass.find_subclasses_by_fqcn(app_class.fqcn)
            if subclasses:
                app_class.subclasses = subclasses
            app_class.sort_members()
        # Resolve superclasses using superclass_index
        for app_class in _app_classes_with_superclass(app_classes):
            superclass_list = _get_superclasses_for_class(superclass_index,
                                                          app_class.superclass)
            if superclass_list:
                app_class.superclasses += superclass_list
        _print_verbose(f' Done in {(time.time() - start_time):.1f} s.')
        api_dir = os.path.join(outputdir, 'api')
        resources_dir = os.path.join(outputdir, 'resources')
        pkg_idx_file = os.path.join(outputdir, 'packages.html')
        cls_idx_file_frame = os.path.join(outputdir, 'classes-frame.html')
        cls_idx_file_noframe = os.path.join(outputdir, 'classes-noframe.html')
        if do_deletes:
            # Delete API directory and index files
            start_time = time.time()
            _print_verbose('Deleting existing files (if found)...', end='',
                           flush=True)
            _remove_dir(api_dir)
            _remove_dir(resources_dir)
            if os.path.exists(pkg_idx_file):
                os.remove(pkg_idx_file)
            if os.path.exists(cls_idx_file_frame):
                os.remove(cls_idx_file_frame)
            if os.path.exists(cls_idx_file_noframe):
                os.remove(cls_idx_file_noframe)
            _print_verbose(f' Done in {(time.time() - start_time):.1f} s.')
        # Produce per-class files
        start_time = time.time()
        _print_verbose('Writing files...', end='', flush=True)
        for app_class in app_classes:
            _write_class_file_html(outputdir, app_class)
        _print_verbose(f' Done in {(time.time() - start_time):.1f} s.')
        # Produce indexes
        start_time = time.time()
        _print_verbose('Writing indexes...', end='', flush=True)
        _write_class_index(app_classes, cls_idx_file_frame,
                           target='classFrame')
        _write_class_index(app_classes, cls_idx_file_noframe)
        packages = sorted(AppClass.package_index.keys())
        _write_package_index(packages, pkg_idx_file)
        for pkg in packages:
            _write_package_overview(pkg, os.path.join(api_dir,
                                    *pkg.split(sep=':'), '0package.html'))
        if not os.path.exists(resources_dir):
            resources_src = resource_filename(__name__, 'resources')
            shutil.copytree(resources_src, resources_dir)
            os.replace(os.path.join(resources_dir, 'index.html'),
                       os.path.join(outputdir, 'index.html'))
            os.replace(os.path.join(resources_dir, 'start-page.html'),
                       os.path.join(outputdir, 'start-page.html'))
        _print_verbose(f' Done in {(time.time() - start_time):.1f} s.')
    else:
        _logger.warning('No classes found')


def appclassdoc_cli():
    """The CLI for AppClassDoc."""
    assert sys.version_info >= (3, 6), \
           'Python 3.6+ is required to run this script'
    parser = argparse.ArgumentParser(
        description=('Generate API documentation for PeopleSoft Application '
                     'Classes.'))
    parser.add_argument(
        '-v', '--verbosity', action='count', default=0,
        help='increase output verbosity')
    parser.add_argument(
        '-o', '--outputdir', default=os.getcwd(),
        help=('the output directory for the generated documentation files '
              '(defaults to the current directory)'))
    parser.add_argument(
        '-p', '--private', action='store_true', default=False,
        help='include private class members in documentation')
    parser.add_argument(
        '-n', '--nodelete', dest='do_deletes', action='store_false',
        help='avoid deleting files already in the target directory')
    parser.add_argument(
        'files', metavar='file_or_dir', nargs='+',
        help=('one or more source files or directories to process recursively '
              '(wildcards accepted)'))
    args = parser.parse_args()
    if args.verbosity == 2:
        logging.basicConfig(level=logging.INFO)
    elif args.verbosity > 2:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig()
    generate_appclassdoc(args.outputdir.rstrip(os.sep), args.private,
                         args.do_deletes, args.files,
                         verbose_output=(args.verbosity > 0))
